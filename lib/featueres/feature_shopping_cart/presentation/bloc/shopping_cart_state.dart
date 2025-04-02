import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';

abstract class ShoppingCartState {}

class ShoppingCartInitial extends ShoppingCartState {}

class ShoppingCartLoading extends ShoppingCartState {}

class ShoppingCartLoaded extends ShoppingCartState {
  final ShoppingCart cart;
  ShoppingCartLoaded(this.cart);
}

class ShoppingCartError extends ShoppingCartState {
  final String message;
  ShoppingCartError(this.message);
}
