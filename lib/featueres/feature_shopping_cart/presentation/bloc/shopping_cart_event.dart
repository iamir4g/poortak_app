import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';

abstract class ShoppingCartEvent {}

class GetCartEvent extends ShoppingCartEvent {}

class AddToCartEvent extends ShoppingCartEvent {
  final ShoppingCartItem item;
  AddToCartEvent(this.item);
}

class RemoveFromCartEvent extends ShoppingCartEvent {
  final String itemId;
  RemoveFromCartEvent(this.itemId);
}

class UpdateQuantityEvent extends ShoppingCartEvent {
  final String title;
  final int quantity;
  UpdateQuantityEvent(this.title, this.quantity);
}

class ClearCartEvent extends ShoppingCartEvent {}

// Local Cart Events
class AddToLocalCartEvent extends ShoppingCartEvent {
  final String type;
  final String itemId;
  AddToLocalCartEvent(this.type, this.itemId);
}

class GetLocalCartEvent extends ShoppingCartEvent {}

class RemoveFromLocalCartEvent extends ShoppingCartEvent {
  final String type;
  final String itemId;
  RemoveFromLocalCartEvent(this.type, this.itemId);
}

class ClearLocalCartEvent extends ShoppingCartEvent {}

class SyncLocalCartToBackendEvent extends ShoppingCartEvent {}
