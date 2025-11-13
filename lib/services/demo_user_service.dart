import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';

class DemoUserService {
  static const String _demoEmail = 'demo@storeffice.com';
  static const String _demoPassword = 'DemoPassword123!';

  static Future<AuthResponse> createDemoUser() async {
    final client = Supabase.instance.client;
    
    try {
      // Try to sign up the demo user (this will fail if user already exists, which is expected)
      try {
        await client.auth.signUp(
          email: _demoEmail,
          password: _demoPassword,
        );
      } catch (e) {
        // If user already exists, that's fine - we'll just sign in
      }

      // Sign in the demo user
      final response = await client.auth.signInWithPassword(
        email: _demoEmail,
        password: _demoPassword,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to create/access demo account: $e');
    }
  }

  static Future<AuthResponse> getDemoUser() async {
    return await createDemoUser();
  }

  static String getDemoEmail() => _demoEmail;
}