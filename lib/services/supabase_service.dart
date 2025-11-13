import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/office_space_model.dart';
import '../models/product_model.dart';
import '../models/booking_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get user profile with all details
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return UserProfile.fromMap(response);
    } catch (e) {
      // If profile doesn't exist, create a basic profile object
      return UserProfile(
        id: userId,
        email: await _getUserEmail(userId),
        roles: ['customer'],
      );
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _client
          .from('profiles')
          .upsert(profile.toMap())
          .eq('id', profile.id);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Get office spaces with all details
  Future<List<OfficeSpace>> getOfficeSpaces() async {
    try {
      final response = await _client
          .from('office_spaces')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return response.map((item) => OfficeSpace.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch office spaces: $e');
    }
  }

  // Get office space by ID
  Future<OfficeSpace> getOfficeSpace(String id) async {
    try {
      final response = await _client
          .from('office_spaces')
          .select('*')
          .eq('id', id)
          .single();
      return OfficeSpace.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch office space: $e');
    }
  }

  // Add office space
  Future<void> addOfficeSpace(OfficeSpace officeSpace) async {
    try {
      await _client.from('office_spaces').insert(officeSpace.toMap()).select();
    } catch (e) {
      throw Exception('Failed to add office space: $e');
    }
  }

  // Update office space
  Future<void> updateOfficeSpace(OfficeSpace officeSpace) async {
    try {
      await _client
          .from('office_spaces')
          .update(officeSpace.toMap())
          .eq('id', officeSpace.id);
    } catch (e) {
      throw Exception('Failed to update office space: $e');
    }
  }

  // Get products with all details
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return response.map((item) => Product.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get product by ID
  Future<Product> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('id', id)
          .single();
      return Product.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Add product
  Future<void> addProduct(Product product) async {
    try {
      await _client.from('products').insert(product.toMap()).select();
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      await _client
          .from('products')
          .update(product.toMap())
          .eq('id', product.id);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*')
          .eq('customer_id', userId)
          .order('start_date', ascending: false);
      return response.map((item) => Booking.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  // Get booking by ID
  Future<Booking> getBooking(String id) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*')
          .eq('id', id)
          .single();
      return Booking.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  // Create booking
  Future<void> createBooking(Booking booking) async {
    try {
      await _client.from('bookings').insert(booking.toMap()).select();
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update booking
  Future<void> updateBooking(Booking booking) async {
    try {
      await _client
          .from('bookings')
          .update(booking.toMap())
          .eq('id', booking.id);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  // Get user favorites
  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      final response = await _client
          .from('favorites')
          .select('*, target_id, target_type')
          .eq('user_id', userId);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user favorites: $e');
    }
  }

  // Add to favorites
  Future<void> addToFavorites(String userId, String targetId, String targetType) async {
    try {
      await _client.from('favorites').insert({
        'user_id': userId,
        'target_id': targetId,
        'target_type': targetType,
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String targetId, String targetType) async {
    try {
      await _client.from('favorites')
          .delete()
          .match({
            'user_id': userId,
            'target_id': targetId,
            'target_type': targetType,
          });
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Helper method to get user email from auth
  Future<String> _getUserEmail(String userId) async {
    try {
      final user = await _client.auth.getUser();
      return user.user?.email ?? 'unknown@example.com';
    } catch (e) {
      return 'unknown@example.com';
    }
  }

  // Track user analytics event
  Future<void> trackAnalyticsEvent(String eventType, {Map<String, dynamic>? eventData, String? userId}) async {
    try {
      final data = {
        'event_type': eventType,
        'event_data': eventData ?? {},
        'platform': 'flutter',
        'app_version': '1.0.0', // Would come from package_info
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
      };
      await _client.from('analytics_events').insert(data);
    } catch (e) {
      // Don't throw error for analytics as it's non-critical
      print('Failed to track analytics event: $e');
    }
  }

  // Submit app feedback
  Future<void> submitFeedback(String type, String title, String description, {String? userId, String? platform, String? appVersion, Map<String, dynamic>? deviceInfo}) async {
    try {
      final data = {
        'type': type,
        'title': title,
        'description': description,
        'user_id': userId,
        'platform': platform,
        'app_version': appVersion,
        'device_info': deviceInfo ?? {},
      };
      await _client.from('app_feedback').insert(data);
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }
}