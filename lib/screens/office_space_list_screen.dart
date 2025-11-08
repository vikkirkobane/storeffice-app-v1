import 'package:flutter/material.dart';
import '../models/office_space_model.dart';
import '../services/firestore_service.dart';
import './booking_screen.dart'; // Import the booking screen

class OfficeSpaceListScreen extends StatelessWidget {
  const OfficeSpaceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Office Spaces'),
      ),
      body: StreamBuilder<List<OfficeSpace>>(
        stream: firestoreService.getOfficeSpaces(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final officeSpaces = snapshot.data ?? [];

          if (officeSpaces.isEmpty) {
            return const Center(child: Text('No office spaces available.'));
          }

          return ListView.builder(
            itemCount: officeSpaces.length,
            itemBuilder: (context, index) {
              final space = officeSpaces[index];
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
          );
        },
      ),
    );
  }
}
