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

// Local Cart States
class LocalCartLoaded extends ShoppingCartState {
  final List<Map<String, dynamic>> items;
  LocalCartLoaded(this.items);
}

class LocalCartItemAdded extends ShoppingCartState {
  final List<Map<String, dynamic>> items;
  LocalCartItemAdded(this.items);
}

class LocalCartItemRemoved extends ShoppingCartState {
  final List<Map<String, dynamic>> items;
  LocalCartItemRemoved(this.items);
}

class LocalCartCleared extends ShoppingCartState {}

class LocalCartSyncSuccess extends ShoppingCartState {}

class LocalCartSyncError extends ShoppingCartState {
  final String message;
  LocalCartSyncError(this.message);
}
