import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';

class ShoppingCartRepository {
  ShoppingCart _cart = ShoppingCart();

  Future<ShoppingCart> getCart() async {
    return _cart;
  }

  Future<ShoppingCart> addToCart(ShoppingCartItem item) async {
    _cart.addItem(item);
    return _cart;
  }

  Future<ShoppingCart> removeFromCart(String title) async {
    _cart.removeItem(title);
    return _cart;
  }

  Future<ShoppingCart> updateQuantity(String title, int quantity) async {
    _cart.updateQuantity(title, quantity);
    return _cart;
  }

  Future<ShoppingCart> clearCart() async {
    _cart = ShoppingCart();
    return _cart;
  }
}
