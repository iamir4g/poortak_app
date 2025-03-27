import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_shopping_cart/data/models/shopping_cart_model.dart';

class ShoppingCartRepository {
  ShoppingCart _cart = ShoppingCart();

  Future<DataState<ShoppingCart>> getCart() async {
    return DataSuccess(_cart);
  }

  Future<DataState<ShoppingCart>> addToCart(ShoppingCartItem item) async {
    _cart.addItem(item);
    return DataSuccess(_cart);
  }

  Future<DataState<ShoppingCart>> removeFromCart(String title) async {
    _cart.removeItem(title);
    return DataSuccess(_cart);
  }

  Future<DataState<ShoppingCart>> updateQuantity(
      String title, int quantity) async {
    _cart.updateQuantity(title, quantity);
    return DataSuccess(_cart);
  }

  Future<DataState<ShoppingCart>> clearCart() async {
    _cart = ShoppingCart();
    return DataSuccess(_cart);
  }
}
