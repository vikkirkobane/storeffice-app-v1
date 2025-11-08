import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AppUser> getUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('id, email, role')
          .eq('id', userId)
          .single();

      return AppUser(
        id: response['id'],
        email: response['email'],
        role: response['role'],
      );
    } catch (e) {
      // If user doesn't exist in the users table, create a basic user object
      // This might happen if the user signed up via Auth but hasn't been added to the users table
      return AppUser(
        id: userId,
        email: 'unknown@example.com', // This will be updated when we fetch from auth
        role: 'Customer', // Default role
      );
    }
  }

  Future<List<Map<String, dynamic>>> getOfficeSpaces() async {
    try {
      final response = await _client
          .from('office_spaces')
          .select('*')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch office spaces: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<void> addOfficeSpace(Map<String, dynamic> data) async {
    try {
      await _client.from('office_spaces').insert(data).select();
    } catch (e) {
      throw Exception('Failed to add office space: $e');
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    try {
      await _client.from('products').insert(data).select();
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    try {
      await _client.from('bookings').insert(data).select();
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }
}