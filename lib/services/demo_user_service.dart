import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';

class DemoUserService {
  static const String _demoEmail = 'demo@storeffice.com';
  static const String _demoPassword = 'DemoPassword123!';
  static const String _demoRole = 'Customer';

  /// Creates or accesses the demo user account
  static Future<AuthResponse> createDemoUser() async {
    final client = Supabase.instance.client;
    
    try {
      // Try to sign in first (in case the user already exists)
      try {
        final response = await client.auth.signInWithPassword(
          email: _demoEmail,
          password: _demoPassword,
        );
        return response;
      } catch (signInError) {
        // If sign in fails, we'll try to create the user
        print('Demo user sign in failed: $signInError');
        print('Attempting to create demo user...');
      }

      // If sign in failed, try to create the user
      final response = await client.auth.signUp(
        email: _demoEmail,
        password: _demoPassword,
      );

      // If the user was just created, we need to make sure they have a profile
      if (response.user != null) {
        // Check if profile already exists
        final profileCheck = await client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();

        if (profileCheck.isEmpty) {
          // Create profile for the demo user
          await client.from('profiles').upsert({
            'id': response.user!.id,
            'email': _demoEmail,
            'roles': [_demoRole.toLowerCase()],
          });
        }
      }

      // Now try to sign in again with the correct credentials
      final signInResponse = await client.auth.signInWithPassword(
        email: _demoEmail,
        password: _demoPassword,
      );

      return signInResponse;
    } catch (e) {
      throw Exception('Failed to create/access demo account: $e');
    }
  }

  /// Gets the demo user, creating it if necessary
  static Future<AuthResponse> getDemoUser() async {
    return await createDemoUser();
  }

  /// Checks if the demo user exists in the system
  static Future<bool> demoUserExists() async {
    try {
      final client = Supabase.instance.client;
      // Try to sign in to check if user exists
      final response = await client.auth.signInWithPassword(
        email: _demoEmail,
        password: _demoPassword,
      );
      
      // If successful, sign out immediately and return true
      await client.auth.signOut();
      return true;
    } catch (e) {
      // If sign in fails, the user probably doesn't exist
      return false;
    }
  }

  /// Creates the demo user if it doesn't exist, for first-time setup
  static Future<AuthResponse> ensureDemoUserExists() async {
    final exists = await demoUserExists();
    
    if (!exists) {
      // Try to create the user by signing up
      return await createDemoUser();
    } else {
      // User exists, just sign in
      final client = Supabase.instance.client;
      return await client.auth.signInWithPassword(
        email: _demoEmail,
        password: _demoPassword,
      );
    }
  }

  static String getDemoEmail() => _demoEmail;
  static String getDemoPassword() => _demoPassword;
}