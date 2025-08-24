class ShoppingCartItem {
  final String title;
  final String description;
  final String image;
  final bool isLock;
  final int price;
  final String? itemId;
  final String? type;
  final int? quantity;
  final Map<String, dynamic>? source;

  ShoppingCartItem({
    required this.title,
    required this.description,
    required this.image,
    required this.isLock,
    required this.price,
    this.itemId,
    this.type,
    this.quantity,
    this.source,
  });

  // double get totalPrice => quantity * 100; // Assuming each item costs 100
}

class ShoppingCart {
  final String? id;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<ShoppingCartItem> items; // Remove final to allow modification
  final int? subTotal;
  final int? grandTotal;

  ShoppingCart({
    this.id,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.subTotal,
    this.grandTotal,
  });

  // double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  // int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(ShoppingCartItem item) {
    final existingItemIndex = items.indexWhere((i) => i.title == item.title);
    if (existingItemIndex != -1) {
      // items[existingItemIndex].quantity++;
    } else {
      items = [...items, item];
    }
  }

  void removeItem(String title) {
    items = items.where((item) => item.title != title).toList();
  }

  void updateQuantity(String title, int quantity) {
    final index = items.indexWhere((item) => item.title == title);
    if (index != -1) {
      // items[index].quantity = quantity;
    }
  }
}
