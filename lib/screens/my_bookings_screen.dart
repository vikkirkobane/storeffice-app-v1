import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see your bookings.'))
          : StreamBuilder<List<Booking>>(
              stream: _firestoreService.getBookingsForUser(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data ?? [];

                if (bookings.isEmpty) {
                  return const Center(child: Text('You have no bookings yet.'));
                }

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Booking for Office Space #${booking.officeSpaceId.substring(0, 6)}...'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start: ${booking.startTime.toLocal()}'),
                            Text('End: ${booking.endTime.toLocal()}'),
                            Text('Total Price: \$${booking.totalPrice.toStringAsFixed(2)}'),
                            Text('Status: ${booking.status}', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
