class OfficeSpace {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final List<String> amenities;
  final int capacity;
  final Map<String, double> pricing;
  final String status;

  OfficeSpace({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.amenities,
    required this.capacity,
    required this.pricing,
    this.status = 'active',
  });

  // Factory constructor to create an OfficeSpace from a Supabase row
  factory OfficeSpace.fromMap(Map<String, dynamic> map) {
    return OfficeSpace(
      id: map['id']?.toString() ?? '',
      ownerId: map['owner_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      photos: List<String>.from(map['photos'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      capacity: map['capacity']?.toInt() ?? 0,
      pricing: {
        'hourly': map['price_per_hour']?.toDouble() ?? 0.0,
      },
      status: map['status'] ?? 'active',
    );
  }

  // Method to convert an OfficeSpace object to a map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'amenities': amenities,
      'capacity': capacity,
      'price_per_hour': pricing['hourly'],
      'status': status,
    };
  }
}
