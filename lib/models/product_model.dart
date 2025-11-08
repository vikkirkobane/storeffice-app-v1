class Product {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      sellerId: map['seller_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
