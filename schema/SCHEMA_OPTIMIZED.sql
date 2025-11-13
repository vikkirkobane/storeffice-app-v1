-- Storeffice App - Database Schema for OTP-based Authentication
-- Compatible with Flutter app implementation

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================
-- Schema: public (application)
-- ========================
CREATE SCHEMA IF NOT EXISTS public;

-- profiles table - matches the Flutter app's user model
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE,
  roles TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles
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

-- office_spaces table - for office booking functionality
CREATE TABLE IF NOT EXISTS public.office_spaces (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid,
  title text,
  description text,
  location jsonb,
  photos text[] DEFAULT '{}',
  amenities text[] DEFAULT '{}',
  capacity int DEFAULT 1,
  pricing jsonb,
  availability jsonb[] DEFAULT '{}',
  thumbnail_photo text,
  search_keywords text[],
  rating numeric DEFAULT 0,
  review_count int DEFAULT 0,
  view_count int DEFAULT 0,
  favorite_count int DEFAULT 0,
  is_active boolean DEFAULT true,
  is_featured boolean DEFAULT false,
  verification_status text DEFAULT 'pending' CHECK (verification_status = ANY (ARRAY['pending','verified','rejected'])),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- products table - for e-commerce functionality
CREATE TABLE IF NOT EXISTS public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid,
  storage_id uuid,
  title text,
  description text,
  category text,
  subcategory text,
  price numeric,
  images text[] DEFAULT '{}',
  inventory int DEFAULT 0,
  sku text,
  thumbnail_image text,
  search_keywords text[],
  tags text[],
  weight numeric,
  dimensions jsonb,
  shipping_info jsonb,
  rating numeric DEFAULT 0,
  review_count int DEFAULT 0,
  view_count int DEFAULT 0,
  favorite_count int DEFAULT 0,
  sales_count int DEFAULT 0,
  is_active boolean DEFAULT true,
  is_featured boolean DEFAULT false,
  verification_status text DEFAULT 'pending' CHECK (verification_status = ANY (ARRAY['pending','verified','rejected'])),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- bookings table - for office space bookings
CREATE TABLE IF NOT EXISTS public.bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid,
  space_id uuid,
  start_date timestamptz,
  end_date timestamptz,
  total_price numeric,
  status text DEFAULT 'pending' CHECK (status = ANY (ARRAY['pending','confirmed','cancelled','completed','no_show'])),
  payment_id uuid,
  check_in_time timestamptz,
  check_out_time timestamptz,
  qr_code text,
  special_requests text,
  cancellation_policy jsonb,
  cancellation_reason text,
  cancelled_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- orders table - for product orders (with RLS enabled)
CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid,
  items jsonb,
  subtotal numeric,
  tax_amount numeric DEFAULT 0,
  shipping_amount numeric DEFAULT 0,
  total_amount numeric,
  shipping_address jsonb,
  billing_address jsonb,
  status text DEFAULT 'pending' CHECK (status = ANY (ARRAY['pending','confirmed','processing','shipped','delivered','cancelled','refunded'])),
  tracking_number text,
  estimated_delivery timestamptz,
  actual_delivery timestamptz,
  delivery_instructions text,
  payment_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "orders: owner_select" ON public.orders
  FOR SELECT TO authenticated
  USING (customer_id = (SELECT auth.uid())::uuid);
CREATE POLICY IF NOT EXISTS "orders: owner_insert" ON public.orders
  FOR INSERT TO authenticated
  WITH CHECK (customer_id = (SELECT auth.uid())::uuid);
CREATE POLICY IF NOT EXISTS "orders: owner_update" ON public.orders
  FOR UPDATE TO authenticated
  USING (customer_id = (SELECT auth.uid())::uuid)
  WITH CHECK (customer_id = (SELECT auth.uid())::uuid);

-- user_carts table - for shopping cart functionality
CREATE TABLE IF NOT EXISTS public.user_carts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  product_id uuid,
  quantity int DEFAULT 1 CHECK (quantity > 0),
  added_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- OTP codes table - for OTP-based authentication
CREATE TABLE IF NOT EXISTS public.otp_codes (
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

-- ========================
-- Database Functions for OTP Management
-- ========================

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

-- ========================
-- Cleanup Job for Expired OTPs
-- ========================
-- Enable pg_cron extension if not already enabled (requires superuser privilege to enable)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create a scheduled job to clean up expired OTPs every day at 2 AM
-- This should be run after pg_cron is enabled
-- SELECT cron.schedule(
--     'clean-expired-otps', 
--     '0 2 * * *',  -- Every day at 2 AM
--     $$DELETE FROM otp_codes WHERE expires_at < NOW() AND used = FALSE$$
-- );

-- ========================
-- Indexes for Performance
-- ========================
CREATE INDEX idx_profiles_id ON public.profiles(id);
CREATE INDEX idx_office_spaces_owner_id ON public.office_spaces(owner_id);
CREATE INDEX idx_products_merchant_id ON public.products(merchant_id);
CREATE INDEX idx_bookings_customer_id ON public.bookings(customer_id);
CREATE INDEX idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX idx_user_carts_user_id ON public.user_carts(user_id);