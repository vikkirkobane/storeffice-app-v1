import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final bookings = await _supabaseService.getUserBookings(user.id);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see your bookings.'))
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
                  ? const Center(child: Text('You have no bookings yet.'))
                  : ListView.builder(
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Booking for Office Space #${booking['office_space_id']?.toString().substring(0, 6) ?? 'N/A'}...'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start: ${DateTime.tryParse(booking['start_time'] ?? '').toString()}'),
                                Text('End: ${DateTime.tryParse(booking['end_time'] ?? '').toString()}'),
                                Text('Total Price: \$${(booking['total_price'] as num?)?.toStringAsFixed(2) ?? 'N/A'}'),
                                Text('Status: ${booking['status'] ?? 'Unknown'}', 
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
