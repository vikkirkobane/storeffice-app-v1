import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../config.dart'; // Import the config file

/// Custom OTP service for handling OTP-based authentication with email verification
/// Supports the following purposes as defined in the SUPABASE_OTP_IMPLEMENTATION_GUIDE.md:
/// - 'signup': For new user registration
/// - 'login': For first-time OTP-based login (no password required)
/// - 'first_login': For existing users logging in for the first time via OTP
/// - 'password_reset': For password reset functionality
class CustomOtpService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _supabaseUrl = Config.supabaseUrl;
  final String _anonKey = Config.supabaseAnonKey;
  
  // Store the last time an OTP was sent for each email and purpose
  final Map<String, DateTime> _lastOtpSent = {};

  // Minimum time interval between OTP requests (in seconds)
  static const int _otpInterval = 60;

  /// Check if enough time has passed since the last OTP was sent
  bool canSendOtp(String email, String purpose) {
    final key = '${email}_$purpose';
    if (!_lastOtpSent.containsKey(key)) {
      return true;
    }
    
    final lastSent = _lastOtpSent[key]!;
    final now = DateTime.now();
    final difference = now.difference(lastSent).inSeconds;
    
    return difference >= _otpInterval;
  }

  /// Get the remaining time before a new OTP can be requested
  int getRemainingTime(String email, String purpose) {
    final key = '${email}_$purpose';
    if (!_lastOtpSent.containsKey(key)) {
      return 0;
    }
    
    final lastSent = _lastOtpSent[key]!;
    final now = DateTime.now();
    final difference = now.difference(lastSent).inSeconds;
    
    return _otpInterval - difference > 0 ? _otpInterval - difference : 0;
  }

  /// Record the time when OTP was sent
  void recordOtpSent(String email, String purpose) {
    final key = '${email}_$purpose';
    _lastOtpSent[key] = DateTime.now();
  }

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
          'X-Client-Info': 'storeffice-flutter-app',
        },
        body: jsonEncode({'email': email, 'purpose': purpose}),
      );

      if (response.statusCode == 200) {
        // Record the time this OTP was sent
        recordOtpSent(email, purpose);
        return true;
      } else if (response.statusCode == 400) {
        // More specific error handling for common 400 responses
        final errorBody = response.body.toLowerCase();
        if (errorBody.contains('invalid') || errorBody.contains('email')) {
          throw Exception('Invalid email address provided');
        } else if (errorBody.contains('rate') || errorBody.contains('limit')) {
          throw Exception('Too many requests. Please wait before trying again');
        } else {
          throw Exception('Bad request: ${response.body}');
        }
      } else {
        throw Exception('Failed to generate OTP (Status: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Re-throw with more context
      if (e is! Exception) {
        // If it's not already an Exception, convert it
        throw Exception('Error generating OTP: $e');
      }
      rethrow;
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
          'X-Client-Info': 'storeffice-flutter-app',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'purpose': purpose,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('success')) {
          return data['success'] == true;
        } else {
          // For compatibility with potential different response formats
          return true;
        }
      } else if (response.statusCode == 400) {
        // Handle specific error messages from the database function
        final errorBody = response.body.toLowerCase();
        if (errorBody.contains('already been used')) {
          throw Exception('OTP code has already been used. Please request a new one');
        } else if (errorBody.contains('expired')) {
          throw Exception('OTP code has expired. Please request a new one');
        } else if (errorBody.contains('invalid') || errorBody.contains('code') || errorBody.contains('otp')) {
          throw Exception('Invalid OTP code entered');
        } else {
          throw Exception('Verification failed: ${response.body}');
        }
      } else if (response.statusCode == 500) {
        // Check for specific server errors
        final errorBody = response.body.toLowerCase();
        if (errorBody.contains('rate limit')) {
          throw Exception('Rate limit exceeded. Please wait before trying again');
        } else {
          throw Exception('Server error during verification: ${response.body}');
        }
      } else {
        throw Exception('Failed to verify OTP (Status: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Re-throw with more context
      if (e is! Exception) {
        // If it's not already an Exception, convert it
        throw Exception('Error verifying OTP: $e');
      }
      rethrow;
    }
  }

  /// Create user account with Supabase auth and initiate OTP flow
  Future<AuthResponse> createUserAccount(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Error creating user account: $e');
    }
  }

  /// Complete the registration by creating profile after OTP verification
  Future<void> createProfileAfterVerification(String userId, String email, String role) async {
    try {
      await _client
          .from('profiles')
          .upsert({
            'id': userId,
            'email': email,
            'roles': [role.toLowerCase()],
          });
    } catch (e) {
      throw Exception('Error creating profile: $e');
    }
  }

  /// Sign in user after successful OTP verification
  Future<void> signInUser(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error signing in user: $e');
    }
  }
}