import 'package:flutter/material.dart';
import '../models/office_space_model.dart';
import '../services/supabase_service.dart';
import './booking_screen.dart'; // Import the booking screen

class OfficeSpaceListScreen extends StatefulWidget {
  const OfficeSpaceListScreen({super.key});

  @override
  State<OfficeSpaceListScreen> createState() => _OfficeSpaceListScreenState();
}

class _OfficeSpaceListScreenState extends State<OfficeSpaceListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<OfficeSpace> _officeSpaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfficeSpaces();
  }

  Future<void> _loadOfficeSpaces() async {
    try {
      final data = await _supabaseService.getOfficeSpaces();
      setState(() {
        _officeSpaces = data.map((item) => OfficeSpace.fromMap(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading office spaces: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Office Spaces'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _officeSpaces.isEmpty
              ? const Center(child: Text('No office spaces available.'))
              : ListView.builder(
                  itemCount: _officeSpaces.length,
                  itemBuilder: (context, index) {
                    final space = _officeSpaces[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(space.title, style: Theme.of(context).textTheme.titleLarge),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(space.description),
                            const SizedBox(height: 8),
                            Text(
                              'Capacity: ${space.capacity} people',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Price: \$${space.pricing['hourly']?.toStringAsFixed(2) ?? 'N/A'}/hour',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(officeSpace: space),
                              ),
                            );
                          },
                          child: const Text('Book Now'),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
