import 'package:cloud_firestore/cloud_firestore.dart';

class OfficeSpace {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final GeoPoint location;
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
    required this.location,
    required this.photos,
    required this.amenities,
    required this.capacity,
    required this.pricing,
    this.status = 'active',
  });

  // Factory constructor to create an OfficeSpace from a Firestore document
  factory OfficeSpace.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OfficeSpace(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      photos: List<String>.from(data['photos'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      capacity: data['capacity'] ?? 0,
      pricing: Map<String, double>.from(data['pricing'] ?? {}),
      status: data['status'] ?? 'active',
    );
  }

  // Method to convert an OfficeSpace object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'location': location,
      'photos': photos,
      'amenities': amenities,
      'capacity': capacity,
      'pricing': pricing,
      'status': status,
    };
  }
}
