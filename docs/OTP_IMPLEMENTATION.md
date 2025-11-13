# OTP Authentication Implementation Guide

## Overview
This document details the implementation of OTP (One-Time Password) authentication in the Storeffice app. The implementation replaces the traditional email/password login with a more secure and user-friendly OTP-based system.

## Authentication Flow Changes

### Registration Flow
**Before:**
1. Enter email and password
2. Click "Register"
3. Account created and user logged in (if email confirmation disabled)

**After:**
1. Enter email and password
2. Select user role
3. Click "Register"
4. OTP sent to user's email
5. User enters OTP code on verification screen
6. Account verified and user logged in
7. Profile created with selected role

### Login Flow
**Before:**
1. Enter email and password
2. Click "Login"
3. User logged in

**After:**
1. Enter email
2. Click "Send OTP to Email"
3. OTP sent to user's email
4. User enters OTP code on verification screen
5. User logged in after OTP verification

## Technical Implementation

### Supabase Authentication Methods Used
- `signInWithOtp()` - Initiates the OTP login flow
- `verifyOTP()` - Verifies the OTP token with type `OtpType.magiclink`
- `signUp()` - Registers new users and sends signup OTP
- `resend()` - Resends OTP tokens when needed

### User Interface Changes

#### Registration Screen
- Added OTP verification step after registration
- New OTP input screen with resend functionality
- Clear navigation between registration and OTP screens
- Proper error handling for OTP verification

#### Login Screen  
- Removed password field
- Changed "Login" button to "Send OTP to Email"
- Added OTP verification screen
- Resend OTP functionality
- Clear navigation between login and OTP screens

### Security Benefits
- No need to store/remember passwords
- Reduced risk of password-based attacks
- Improved user experience (no more forgotten passwords)
- OTP tokens expire after a short time for security
- Email verification built into the process

## UI/UX Features

### Registration OTP Screen
- Clear display of the email that OTP was sent to
- Large, centered input field for OTP code
- Visual feedback during verification
- Resend OTP button with cooldown
- Back button to return to registration

### Login OTP Screen
- Clear display of the email that OTP was sent to
- Large, centered input field for OTP code
- Visual feedback during verification
- Resend OTP button with cooldown
- Back button to return to login

## Error Handling

### Common Error Scenarios
- Invalid OTP code entered
- Expired OTP token
- Failed to send OTP
- Network connectivity issues
- User account doesn't exist

### User Feedback
- Clear error messages displayed on UI
- Successful OTP resend notifications
- Proper loading states during verification
- Navigation protection to prevent back/forward issues

## Configuration Requirements

### Supabase Dashboard Settings
For the OTP system to work properly, ensure your Supabase project has:

1. **Authentication Settings:**
   - Email provider must be enabled
   - "Secure email change" can be enabled or disabled based on preference
   - Email templates properly configured (optional customization)

2. **Email Provider Configuration:**
   - SMTP settings configured for email delivery
   - Email templates customized for brand consistency (optional)

### Environment Variables
The system continues to use the same environment variables:
- SUPABASE_URL
- SUPABASE_ANON_KEY

## Integration Points

### With Existing Codebase
- Profile creation still works in the background
- All existing user role functionality preserved
- All existing navigation and routing maintained
- All existing UI components and themes preserved
- All existing business logic remains unchanged

### Compatibility
- Works seamlessly with the unified schema
- Maintains cross-platform compatibility (Flutter + Next.js)
- All existing features remain functional
- All existing models and services remain compatible

## User Experience Benefits
- Simplified login process (email only)
- Reduced friction for registration
- Improved security without complexity
- Familiar OTP verification pattern
- Clear feedback at each step
- Resend functionality for convenience

## Testing Considerations
- OTP codes are only valid for a short time (typically 60 seconds)
- Each OTP can only be used once
- Resend functionality has rate limiting in Supabase
- Test with real email addresses to verify delivery

## Next Steps for Production
1. Configure production email settings in Supabase
2. Customize email templates with brand information
3. Implement phone number OTP as an alternative (optional)
4. Add backup authentication methods
5. Monitor email delivery success rates