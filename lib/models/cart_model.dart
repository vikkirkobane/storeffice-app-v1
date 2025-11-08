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

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
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
