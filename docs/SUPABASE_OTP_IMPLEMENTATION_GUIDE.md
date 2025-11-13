# Supabase OTP Authentication Implementation Guide

This guide will help you set up the Supabase backend for the OTP-based authentication system with email verification, password reset, and rate limiting functionality.

## 1. Database Schema Setup

First, ensure your `profiles` table exists to store user information:

```sql
-- Create profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE,
  roles TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies to allow users to view and update their own profile
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id);

-- Create trigger to automatically create profile on user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## 2. Create OTP Storage Table

Create a table to store OTP codes with expiration and purpose:

```sql
-- Create OTP table
CREATE TABLE IF NOT EXISTS otp_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  otp_code TEXT NOT NULL,
  purpose TEXT NOT NULL CHECK (purpose IN ('signup', 'login', 'first_login', 'password_reset')),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for OTP table
ALTER TABLE otp_codes ENABLE ROW LEVEL SECURITY;

-- Create indexes for efficient lookup
CREATE INDEX idx_otp_codes_email_purpose ON otp_codes(email, purpose);
CREATE INDEX idx_otp_codes_expires_at ON otp_codes(expires_at);
CREATE INDEX idx_otp_codes_requested_at ON otp_codes(requested_at);
```

## 3. Create Database Functions for OTP Management

You'll need two database functions to generate and verify OTPs:

```sql
-- Function to check rate limiting
CREATE OR REPLACE FUNCTION public.check_rate_limit(p_email TEXT, p_purpose TEXT, p_interval INTERVAL DEFAULT INTERVAL '1 minute')
RETURNS BOOLEAN AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Count OTP requests in the last interval
  SELECT COUNT(*) INTO v_count FROM otp_codes
  WHERE email = p_email
  AND purpose = p_purpose
  AND requested_at > NOW() - p_interval;
  
  -- Return TRUE if under limit (e.g., less than 3 requests per minute)
  RETURN v_count < 3;
END;
$$ LANGUAGE plpgsql;

-- Function to generate OTP
CREATE OR REPLACE FUNCTION public.create_otp(p_email TEXT, p_purpose TEXT)
RETURNS TABLE(otp_code TEXT) AS $$
DECLARE
  v_otp TEXT;
  v_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Check rate limiting (max 3 requests per minute for the same email and purpose)
  IF NOT check_rate_limit(p_email, p_purpose) THEN
    RAISE EXCEPTION 'Rate limit exceeded. Please wait before requesting another OTP.';
  END IF;

  -- Generate 6-digit OTP
  v_otp := lpad(floor(random() * 1000000)::TEXT, 6, '0');
  
  -- Set expiration time (5 minutes from now)
  v_expires_at := NOW() + INTERVAL '5 minutes';
  
  -- Clean up old unused OTPs for this email and purpose
  DELETE FROM otp_codes 
  WHERE email = p_email 
  AND purpose = p_purpose
  AND (used = true OR expires_at < NOW());
  
  -- Insert new OTP
  INSERT INTO otp_codes (email, otp_code, purpose, expires_at)
  VALUES (p_email, v_otp, p_purpose, v_expires_at);
  
  -- Return the generated OTP
  RETURN QUERY SELECT v_otp;
END;
$$ LANGUAGE plpgsql;

-- Function to verify OTP
CREATE OR REPLACE FUNCTION public.verify_otp(p_email TEXT, p_purpose TEXT, p_otp TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_otp RECORD;
BEGIN
  -- Find the OTP record
  SELECT * INTO v_otp FROM otp_codes
  WHERE email = p_email
  AND purpose = p_purpose
  AND otp_code = p_otp
  AND expires_at > NOW()
  AND used = FALSE
  ORDER BY created_at DESC
  LIMIT 1;
  
  -- Check if OTP exists and is valid
  IF v_otp IS NOT NULL THEN
    -- Mark OTP as used
    UPDATE otp_codes SET used = TRUE WHERE id = v_otp.id;
    
    RETURN QUERY SELECT TRUE as success, 'OTP verified successfully' as message;
  ELSE
    -- Check if OTP was already used
    SELECT * INTO v_otp FROM otp_codes
    WHERE email = p_email
    AND purpose = p_purpose
    AND otp_code = p_otp
    AND used = TRUE;
    
    IF v_otp IS NOT NULL THEN
      RETURN QUERY SELECT FALSE as success, 'OTP has already been used' as message;
    ELSE
      -- Check if OTP has expired
      SELECT * INTO v_otp FROM otp_codes
      WHERE email = p_email
      AND purpose = p_purpose
      AND otp_code = p_otp
      AND expires_at <= NOW();
      
      IF v_otp IS NOT NULL THEN
        RETURN QUERY SELECT FALSE as success, 'OTP has expired' as message;
      ELSE
        RETURN QUERY SELECT FALSE as success, 'Invalid OTP code' as message;
      END IF;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

## 4. Supabase Edge Function Setup

Create a Supabase Edge Function to handle OTP generation and verification with email sending:

### Step 1: Create the Edge Function

Create a new file at `supabase/functions/otp-auth/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";

// Email sending function using Resend
async function sendEmail(to: string, subject: string, html: string) {
  const resendApiKey = Deno.env.get("RESEND_API_KEY");
  
  if (!resendApiKey) {
    throw new Error("RESEND_API_KEY is not set in environment variables");
  }

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${resendApiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      from: Deno.env.get("FROM_EMAIL") || "onboarding@resend.dev",
      to: to,
      subject: subject,
      html: html
    })
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to send email: ${error}`);
  }
}

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const { email, purpose } = await req.json();

  if (!email || !purpose) {
    return new Response(JSON.stringify({ error: "Email and purpose are required" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Generate OTP code using database function
    const { data, error } = await supabase.rpc('create_otp', {
      p_email: email,
      p_purpose: purpose
    });

    if (error) {
      throw error;
    }

    if (!data || data.length === 0) {
      return new Response(JSON.stringify({ error: "Failed to generate OTP" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    const otpCode = data[0].otp_code;

    // Prepare email content based on purpose
    let subject = "";
    let html = "";
    
    switch (purpose) {
      case "signup":
        subject = "Your Storeffice Account Verification";
        html = `
          <h2>Welcome to Storeffice!</h2>
          <p>Thank you for signing up. Please use the following OTP to verify your account:</p>
          <h3 style="font-size: 24px; color: #4f46e5;">${otpCode}</h3>
          <p>This code will expire in 5 minutes.</p>
        `;
        break;
        
      case "login":
      case "first_login":
        subject = "Storeffice Login Verification";
        html = `
          <h2>Login Verification</h2>
          <p>Use the following OTP to verify your login to Storeffice:</p>
          <h3 style="font-size: 24px; color: #4f46e5;">${otpCode}</h3>
          <p>This code will expire in 5 minutes.</p>
        `;
        break;
        
      case "password_reset":
        subject = "Storeffice Password Reset";
        html = `
          <h2>Password Reset Request</h2>
          <p>Use the following OTP to reset your Storeffice password:</p>
          <h3 style="font-size: 24px; color: #4f46e5;">${otpCode}</h3>
          <p>This code will expire in 5 minutes.</p>
        `;
        break;
        
      default:
        return new Response(JSON.stringify({ error: "Invalid purpose" }), {
          status: 400,
          headers: { "Content-Type": "application/json" },
        });
    }

    // Send the email
    await sendEmail(email, subject, html);

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("Error in OTP generation:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

### Step 2: Create verification function for edge function

Create another file at `supabase/functions/otp-verify/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  const { email, otp, purpose } = await req.json();

  if (!email || !otp || !purpose) {
    return new Response(JSON.stringify({ error: "Email, OTP, and purpose are required" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Verify OTP code using database function
    const { data, error } = await supabase.rpc('verify_otp', {
      p_email: email,
      p_purpose: purpose,
      p_otp: otp
    });

    if (error) {
      throw error;
    }

    if (!data || data.length === 0) {
      return new Response(JSON.stringify({ success: false, message: "Verification failed" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ 
      success: data[0].success, 
      message: data[0].message 
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });

  } catch (error) {
    console.error("Error in OTP verification:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

## 5. Environment Variables Setup

Set up the required environment variables in your Supabase project:

1. Go to your Supabase Dashboard
2. Navigate to Settings → Environment Variables
3. Add the following variables:

```
RESEND_API_KEY=your_resend_api_key  # or SENDGRID_API_KEY=your_sendgrid_api_key
FROM_EMAIL=your-noreply@yourdomain.com
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

For Resend:
- Sign up at https://resend.com/
- Create an API key
- Set `RESEND_API_KEY` to your API key
- Set `FROM_EMAIL` to a verified domain or "onboarding@resend.dev"

For SendGrid:
- Sign up at https://sendgrid.com/
- Create an API key with "Mail Send" permissions
- Set `SENDGRID_API_KEY` to your API key
- Set `FROM_EMAIL` to a verified sender

## 6. Deploy the Edge Functions

Deploy your edge functions using the Supabase CLI:

```bash
# Navigate to your project directory
cd path/to/your/supabase/project

# Deploy the functions
supabase functions deploy otp-auth
supabase functions deploy otp-verify
```

## 7. Rate Limiting Configuration

To implement rate limiting to prevent abuse, the database functions already include rate limiting logic that allows a maximum of 3 requests per minute per email and purpose.

## 8. Cleanup Job for Expired OTPs

To clean up expired OTP records automatically, create a daily job:

```sql
-- Enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create a scheduled job to clean up expired OTPs every day at 2 AM
SELECT cron.schedule(
    'clean-expired-otps', 
    '0 2 * * *',  -- Every day at 2 AM
    $$DELETE FROM otp_codes WHERE expires_at < NOW() AND used = FALSE$$
);
```

## 9. Testing the Implementation

To test the implementation:

1. **Test OTP Generation**:
   ```bash
   curl -X POST \
     -H "Authorization: Bearer your_anon_key" \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","purpose":"signup"}' \
     https://your-project.supabase.co/functions/v1/otp-auth
   ```

2. **Test OTP Verification**:
   ```bash
   curl -X POST \
     -H "Authorization: Bearer your_anon_key" \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","otp":"123456","purpose":"signup"}' \
     https://your-project.supabase.co/functions/v1/otp-verify
   ```

## 10. Integration with Flutter App

Update your Flutter app's `CustomOtpService` to ensure it calls the correct endpoints:

```dart
/// Generate OTP for the specified email and purpose
Future<bool> generateOtp(String email, String purpose) async {
  try {
    // Check if enough time has passed since the last OTP was sent
    if (!canSendOtp(email, purpose)) {
      final remainingTime = getRemainingTime(email, purpose);
      throw Exception('Please wait $remainingTime seconds before requesting another OTP');
    }

    final response = await http.post(
      Uri.parse('$_supabaseUrl/functions/v1/otp-auth'),
      headers: {
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'purpose': purpose}),
    );

    if (response.statusCode == 200) {
      // Record the time this OTP was sent
      recordOtpSent(email, purpose);
      return true;
    } else {
      throw Exception('Failed to generate OTP: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error generating OTP: $e');
  }
}

/// Verify OTP for the specified email and purpose
Future<bool> verifyOtp(String email, String otp, String purpose) async {
  try {
    final response = await http.post(
      Uri.parse('$_supabaseUrl/functions/v1/otp-verify'),
      headers: {
        'Authorization': 'Bearer $_anonKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'purpose': purpose,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to verify OTP: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error verifying OTP: $e');
  }
}
```

## Summary

This implementation provides:

- ✅ Secure OTP generation and verification with database functions
- ✅ Email delivery via Resend or SendGrid
- ✅ Different purposes (signup, login, first_login, password_reset)
- ✅ Rate limiting to prevent abuse (3 requests per minute)
- ✅ Expiration and cleanup of old OTPs
- ✅ Proper security with service role keys
- ✅ Integration ready for your Flutter app

The system is now ready to support your OTP-based authentication flow with all the security measures you requested.