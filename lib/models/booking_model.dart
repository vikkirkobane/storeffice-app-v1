
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

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id']?.toString() ?? '',
      userId: map['user_id'] ?? '',
      officeSpaceId: map['office_space_id'] ?? '',
      startTime: DateTime.parse(map['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['end_time'] ?? DateTime.now().toIso8601String()),
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'office_space_id': officeSpaceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
    };
  }
}
