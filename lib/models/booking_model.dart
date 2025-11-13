
class Booking {
  final String id;
  final String customerId;
  final String spaceId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final String? paymentId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? qrCode;
  final String? specialRequests;
  final Map<String, dynamic>? cancellationPolicy;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.spaceId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status = 'pending',
    this.paymentId,
    this.checkInTime,
    this.checkOutTime,
    this.qrCode,
    this.specialRequests,
    this.cancellationPolicy,
    this.cancellationReason,
    this.cancelledAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id']?.toString() ?? '',
      customerId: map['customer_id'] ?? '',
      spaceId: map['space_id'] ?? '',
      startDate: DateTime.parse(map['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['end_date'] ?? DateTime.now().toIso8601String()),
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      paymentId: map['payment_id'],
      checkInTime: map['check_in_time'] != null ? DateTime.parse(map['check_in_time']) : null,
      checkOutTime: map['check_out_time'] != null ? DateTime.parse(map['check_out_time']) : null,
      qrCode: map['qr_code'],
      specialRequests: map['special_requests'],
      cancellationPolicy: Map<String, dynamic>.from(map['cancellation_policy'] ?? {}),
      cancellationReason: map['cancellation_reason'],
      cancelledAt: map['cancelled_at'] != null ? DateTime.parse(map['cancelled_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'space_id': spaceId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'payment_id': paymentId,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'qr_code': qrCode,
      'special_requests': specialRequests,
      'cancellation_policy': cancellationPolicy,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }
}
