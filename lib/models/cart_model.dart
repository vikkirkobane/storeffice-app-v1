import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  void increment() {
    quantity++;
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    } 
  }

    factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CartItem(
      productId: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

}

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  double get totalPrice =>
      items.fold(0.0, (total, item) => total + item.price * item.quantity);

  int get totalItems => items.fold(0, (total, item) => total + item.quantity);
}
