# Supabase Email Configuration Guide

## Issue: "Email not confirmed" Error

When attempting to log in right after registration, you may encounter an "email not confirmed" error. This is due to Supabase's default email authentication settings.

## Root Cause
By default, Supabase requires email confirmation for new user accounts as a security measure:
- When a user registers, Supabase sends a confirmation email
- The account remains unconfirmed until the user clicks the confirmation link
- Unconfirmed users cannot log in until their email is verified

## Solutions

### Option 1: Enable Auto-Confirmation (Development Only)
For development/testing purposes, you can disable email confirmation:

1. **Go to your Supabase Dashboard**
2. **Navigate to Authentication > Settings**
3. **Scroll to "Email Templates"**
4. **Find the "Signup with Email" template**
5. **Toggle off "Secure email change" and "Email confirmations"**

OR alternatively:

1. **Go to Authentication > Providers**
2. **Under "Email settings", disable "Email confirmations"**

⚠️ **Warning**: This option is only recommended for development. For production, keep email confirmations enabled.

### Option 2: Complete Email Verification Process
For a production-like environment:

1. **Register your account** in the Storeffice app
2. **Check your email inbox** for a confirmation email from Supabase
3. **Click the confirmation link** in the email
4. **Return to the app** and log in with your credentials

### Option 3: Admin Override (For Testing)
If you need to manually confirm users for testing:

1. **Go to your Supabase Dashboard**
2. **Navigate to Authentication > Users**
3. **Find the user that needs confirmation**
4. **Click the "Edit" button for that user**
5. **Toggle "Email confirmed" to ON**
6. **Save the changes**

## Supabase Dashboard Settings To Check

### For Development Environment:
- **Disable email confirmations** for easier testing
- **Allow all domains** for email registration
- **Add localhost and development URLs** to allowed redirects
- Set redirect URLs to: `http://localhost:3000/*`

### For Production Environment:
- **Keep email confirmations enabled** for security
- **Use proper domain names** in allowed redirects
- **Set up custom email templates** if needed

## Configuration in Supabase Dashboard

### Authentication Settings Path:
1. Project Dashboard
2. Authentication
3. Settings
4. Email templates and security options

### Recommended Development Settings:
- Disable "Secure email change" (for development only)
- Disable "Email confirmations" (for development only)
- Allow "Email" sign-in method
- Add redirect URLs: 
  - `http://localhost:3000/*`
  - `http://localhost:3000/**/*`
  - Your deployed URL for production

## Code Considerations

The Storeffice app handles this gracefully in the registration flow, but you may want to add:

- Email verification status indicators
- Resend confirmation email functionality
- Better error messaging for users

## Troubleshooting Steps

### If the error persists:
1. **Verify your Supabase project email settings**
2. **Check that the anon key has proper permissions**
3. **Ensure the schema is properly deployed**
4. **Confirm that the RLS policies are configured correctly**

### Common Supabase Auth Settings for Development:
```
Email confirmations: DISABLED (for development only)
Secure email change: DISABLED (for development only)
Allow sign ups: ENABLED
Enable password recovery: ENABLED
```

## Security Note
While disabling email confirmations makes development easier, remember to re-enable them for production deployments to maintain security best practices.