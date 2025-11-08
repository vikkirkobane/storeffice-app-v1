
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String officeSpaceId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status; // e.g., 'pending', 'confirmed', 'cancelled'

  Booking({
    required this.id,
    required this.userId,
    required this.officeSpaceId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      officeSpaceId: data['officeSpaceId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'officeSpaceId': officeSpaceId,
      'startTime': startTime,
      'endTime': endTime,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
