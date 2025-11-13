import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';

class DemoDataInitializer {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> initializeDemoData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Add demo office spaces if they don't already exist for this user
      await _addDemoOfficeSpaces(user.id);
      
      // Add demo products if they don't already exist for this user
      await _addDemoProducts(user.id);
      
      // Add demo bookings if they don't already exist for this user
      await _addDemoBookings(user.id);

      print('Demo data initialized successfully');
    } catch (e) {
      print('Error initializing demo data: $e');
    }
  }

  static Future<void> _addDemoOfficeSpaces(String userId) async {
    try {
      // Check if demo office spaces already exist for this user
      final existingSpaces = await _client
          .from('office_spaces')
          .select()
          .eq('owner_id', userId)
          .limit(1);

      if (existingSpaces.isNotEmpty) {
        // Demo spaces already exist for this user
        return;
      }

      // Add sample office spaces
      final officeSpaces = [
        {
          'owner_id': userId,
          'title': 'Modern Co-working Space',
          'description': 'Beautiful modern co-working space with natural light, ergonomic furniture, and high-speed WiFi.',
          'location': {
            'address': '123 Business District, Downtown',
            'city': 'Metropolis',
            'state': 'CA',
            'zipCode': '90210',
            'coordinates': [-118.2437, 34.0522]
          },
          'photos': [
            'https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1497366754035-f200968a6e72?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
          ],
          'amenities': ['WiFi', 'Parking', 'Coffee', 'Printer', 'Meeting Room'],
          'capacity': 10,
          'pricing': {
            'hourly': 15.00,
            'daily': 75.00,
            'weekly': 300.00,
            'monthly': 1000.00
          },
          'is_active': true,
          'is_featured': true,
          'verification_status': 'verified'
        },
        {
          'owner_id': userId,
          'title': 'Executive Boardroom',
          'description': 'Professional boardroom perfect for important meetings and presentations. Includes AV equipment and catering services.',
          'location': {
            'address': '456 Corporate Plaza, Financial District',
            'city': 'Metropolis',
            'state': 'CA',
            'zipCode': '90211',
            'coordinates': [-118.2562, 34.0599]
          },
          'photos': [
            'https://images.unsplash.com/photo-1507842721694-0e5a68584ec6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1556761229-82b5ac3fb6d3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
          ],
          'amenities': ['AV Equipment', 'Catering Available', 'Video Conferencing', 'WiFi'],
          'capacity': 12,
          'pricing': {
            'hourly': 50.00,
            'daily': 300.00
          },
          'is_active': true,
          'is_featured': true,
          'verification_status': 'verified'
        },
        {
          'owner_id': userId,
          'title': 'Creative Studio Space',
          'description': 'Open and flexible creative studio space suitable for artists, designers, and creative professionals.',
          'location': {
            'address': '789 Art District, Creative Quarter',
            'city': 'Metropolis',
            'state': 'CA',
            'zipCode': '90212',
            'coordinates': [-118.2392, 34.0656]
          },
          'photos': [
            'https://images.unsplash.com/photo-1556761239-50d50ecf5e38?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1495571758719-66273b8b42a2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
          ],
          'amenities': ['Natural Light', 'Art Supplies', 'WiFi', 'Storage'],
          'capacity': 6,
          'pricing': {
            'hourly': 20.00,
            'daily': 100.00
          },
          'is_active': true,
          'verification_status': 'verified'
        }
      ];

      await _client.from('office_spaces').insert(officeSpaces);
    } catch (e) {
      print('Error adding demo office spaces: $e');
    }
  }

  static Future<void> _addDemoProducts(String userId) async {
    try {
      // Check if demo products already exist for this merchant
      final existingProducts = await _client
          .from('products')
          .select()
          .eq('merchant_id', userId)
          .limit(1);

      if (existingProducts.isNotEmpty) {
        // Demo products already exist for this user
        return;
      }

      // Add sample products
      final products = [
        {
          'merchant_id': userId,
          'storage_id': null, // Will be assigned later or can link to demo storage
          'title': 'Wireless Bluetooth Headphones',
          'description': 'High-quality wireless headphones with noise cancellation and 30-hour battery life.',
          'category': 'Electronics',
          'subcategory': 'Audio',
          'price': 129.99,
          'images': [
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1572536147248-ac59a8abfa4b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
          ],
          'inventory': 25,
          'sku': 'ELEC-BT-001',
          'is_active': true,
          'is_featured': true,
          'verification_status': 'verified'
        },
        {
          'merchant_id': userId,
          'storage_id': null,
          'title': 'Ergonomic Office Chair',
          'description': 'Premium ergonomic office chair with lumbar support and adjustable height.',
          'category': 'Furniture',
          'subcategory': 'Office',
          'price': 249.99,
          'images': [
            'https://images.unsplash.com/photo-1519947486511-46149fa0a2d3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
            'https://images.unsplash.com/photo-1504672281656-e4981d70514d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
          ],
          'inventory': 10,
          'sku': 'FURN-ERG-002',
          'is_active': true,
          'verification_status': 'verified'
        },
        {
          'merchant_id': userId,
          'storage_id': null,
          'title': 'Reusable Coffee Cup',
          'description': 'Eco-friendly insulated coffee cup that keeps drinks hot for 6 hours.',
          'category': 'Kitchen',
          'subcategory': 'Drinkware',
          'price': 24.99,
          'images': [
            'https://images.unsplash.com/photo-1572448863793-1f378ea8c7c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
          ],
          'inventory': 50,
          'sku': 'KIT-REU-003',
          'is_active': true,
          'is_featured': true,
          'verification_status': 'verified'
        }
      ];

      await _client.from('products').insert(products);
    } catch (e) {
      print('Error adding demo products: $e');
    }
  }

  static Future<void> _addDemoBookings(String userId) async {
    try {
      // This would add sample bookings for the demo user
      // For simplicity, we'll skip this for now, but could be added later
    } catch (e) {
      print('Error adding demo bookings: $e');
    }
  }
}