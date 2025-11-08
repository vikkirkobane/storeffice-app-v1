import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/office_space_model.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

class BookingScreen extends StatefulWidget {
  final OfficeSpace officeSpace;

  const BookingScreen({super.key, required this.officeSpace});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _firestoreService = FirestoreService();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _confirmBooking() async {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time range.')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time cannot be before start time.')),
      );
      return;
    }

    // Using a placeholder for price calculation
    final hourlyRate = widget.officeSpace.pricing['hourly'] ?? 25.0; // Default to 25 if not specified
    final duration = endDateTime.difference(startDateTime);
    final double totalPrice = (duration.inMinutes / 60) * hourlyRate;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final booking = Booking(
        id: '', // Firestore will generate this
        userId: user.uid,
        officeSpaceId: widget.officeSpace.id,
        startTime: startDateTime,
        endTime: endDateTime,
        totalPrice: totalPrice,
        status: 'confirmed',
      );

      await _firestoreService.addBooking(booking);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.officeSpace.title}'), // Corrected: use title instead of name
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date and Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            // Date Picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_selectedDate == null
                  ? 'Select Date'
                  : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]), // Corrected: added closing parenthesis
              onTap: () => _selectDate(context),
            ),
            // Start Time Picker
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(_startTime == null
                  ? 'Select Start Time'
                  : 'Start Time: ${_startTime!.format(context)}'),
              onTap: () => _selectTime(context, true),
            ),
            // End Time Picker
            ListTile(
              leading: const Icon(Icons.access_time_filled),
              title: Text(_endTime == null
                  ? 'Select End Time'
                  : 'End Time: ${_endTime!.format(context)}'),
              onTap: () => _selectTime(context, false),
            ),
            const Spacer(), // Use Spacer to push content to the bottom
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirm Booking'),
                ),
              ),
            const SizedBox(height: 20), // Add some padding at the bottom
          ],
        ),
      ),
    );
  }
}
