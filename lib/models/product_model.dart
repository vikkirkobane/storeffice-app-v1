class Product {
  final String id;
  final String merchantId;
  final String? storageId;
  final String title;
  final String? description;
  final String? category;
  final String? subcategory;
  final double price;
  final List<String> images;
  final int inventory;
  final String? sku;
  final String? thumbnailImage;
  final List<String> searchKeywords;
  final List<String> tags;
  final double? weight;
  final Map<String, dynamic>? dimensions;
  final Map<String, dynamic>? shippingInfo;
  final double rating;
  final int reviewCount;
  final int viewCount;
  final int favoriteCount;
  final int salesCount;
  final bool isActive;
  final bool isFeatured;
  final String verificationStatus;

  Product({
    required this.id,
    required this.merchantId,
    this.storageId,
    required this.title,
    this.description,
    this.category,
    this.subcategory,
    required this.price,
    this.images = const [],
    this.inventory = 0,
    this.sku,
    this.thumbnailImage,
    this.searchKeywords = const [],
    this.tags = const [],
    this.weight,
    this.dimensions,
    this.shippingInfo,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.salesCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.verificationStatus = 'pending',
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      merchantId: map['merchant_id'] ?? '',
      storageId: map['storage_id'],
      title: map['title'] ?? '',
      description: map['description'],
      category: map['category'],
      subcategory: map['subcategory'],
      price: (map['price'] ?? 0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      inventory: map['inventory']?.toInt() ?? 0,
      sku: map['sku'],
      thumbnailImage: map['thumbnail_image'],
      searchKeywords: List<String>.from(map['search_keywords'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      weight: (map['weight'] as num?)?.toDouble(),
      dimensions: Map<String, dynamic>.from(map['dimensions'] ?? {}),
      shippingInfo: Map<String, dynamic>.from(map['shipping_info'] ?? {}),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['review_count']?.toInt() ?? 0,
      viewCount: map['view_count']?.toInt() ?? 0,
      favoriteCount: map['favorite_count']?.toInt() ?? 0,
      salesCount: map['sales_count']?.toInt() ?? 0,
      isActive: map['is_active'] ?? true,
      isFeatured: map['is_featured'] ?? false,
      verificationStatus: map['verification_status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'merchant_id': merchantId,
      'storage_id': storageId,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'images': images,
      'inventory': inventory,
      'sku': sku,
      'thumbnail_image': thumbnailImage,
      'search_keywords': searchKeywords,
      'tags': tags,
      'weight': weight,
      'dimensions': dimensions,
      'shipping_info': shippingInfo,
      'rating': rating,
      'review_count': reviewCount,
      'view_count': viewCount,
      'favorite_count': favoriteCount,
      'sales_count': salesCount,
      'is_active': isActive,
      'is_featured': isFeatured,
      'verification_status': verificationStatus,
    };
  }
}
