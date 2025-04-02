class ShoppingCartItem {
  final String title;
  final String description;
  final String image;
  final bool isLock;
  // int quantity;
  final int price;

  ShoppingCartItem({
    required this.title,
    required this.description,
    required this.image,
    required this.isLock,
    required this.price,
    // this.quantity = 1,
  });

  // double get totalPrice => quantity * 100; // Assuming each item costs 100
}

class ShoppingCart {
  List<ShoppingCartItem> items;

  ShoppingCart({this.items = const []});

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
