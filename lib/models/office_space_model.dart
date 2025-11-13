class OfficeSpace {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final Map<String, dynamic> location; // {address, city, state, zipCode, country, coordinates: [lng, lat]}
  final List<String> photos;
  final List<String> amenities;
  final int capacity;
  final Map<String, dynamic> pricing; // {hourly, daily, weekly, monthly}
  final List<Map<String, dynamic>> availability;
  final String? thumbnailPhoto;
  final List<String> searchKeywords;
  final double rating;
  final int reviewCount;
  final int viewCount;
  final int favoriteCount;
  final bool isActive;
  final bool isFeatured;
  final String verificationStatus;
  final String status;

  OfficeSpace({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.location,
    required this.photos,
    required this.amenities,
    required this.capacity,
    required this.pricing,
    this.availability = const [],
    this.thumbnailPhoto,
    this.searchKeywords = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.verificationStatus = 'pending',
    this.status = 'active',
  });

  // Factory constructor to create an OfficeSpace from a Supabase row
  factory OfficeSpace.fromMap(Map<String, dynamic> map) {
    return OfficeSpace(
      id: map['id']?.toString() ?? '',
      ownerId: map['owner_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      photos: List<String>.from(map['photos'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      capacity: map['capacity']?.toInt() ?? 0,
      pricing: Map<String, dynamic>.from(map['pricing'] ?? {}),
      availability: List<Map<String, dynamic>>.from(map['availability'] ?? []),
      thumbnailPhoto: map['thumbnail_photo'],
      searchKeywords: List<String>.from(map['search_keywords'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count']?.toInt() ?? 0,
      viewCount: map['view_count']?.toInt() ?? 0,
      favoriteCount: map['favorite_count']?.toInt() ?? 0,
      isActive: map['is_active'] ?? true,
      isFeatured: map['is_featured'] ?? false,
      verificationStatus: map['verification_status'] ?? 'pending',
      status: map['status'] ?? 'active',
    );
  }

  // Method to convert an OfficeSpace object to a map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'location': location,
      'photos': photos,
      'amenities': amenities,
      'capacity': capacity,
      'pricing': pricing,
      'availability': availability,
      'thumbnail_photo': thumbnailPhoto,
      'search_keywords': searchKeywords,
      'rating': rating,
      'review_count': reviewCount,
      'view_count': viewCount,
      'favorite_count': favoriteCount,
      'is_active': isActive,
      'is_featured': isFeatured,
      'verification_status': verificationStatus,
      'status': status,
    };
  }
}
