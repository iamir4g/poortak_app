import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';

abstract class ShoppingCartEvent {}

class GetCartEvent extends ShoppingCartEvent {}

class AddToCartEvent extends ShoppingCartEvent {
  final ShoppingCartItem item;
  AddToCartEvent(this.item);
}

class RemoveFromCartEvent extends ShoppingCartEvent {
  final String title;
  RemoveFromCartEvent(this.title);
}

class UpdateQuantityEvent extends ShoppingCartEvent {
  final String title;
  final int quantity;
  UpdateQuantityEvent(this.title, this.quantity);
}

class ClearCartEvent extends ShoppingCartEvent {}
