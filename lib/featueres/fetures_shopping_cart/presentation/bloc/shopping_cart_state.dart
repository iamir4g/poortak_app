part of 'shopping_cart_cubit.dart';

class ShoppingCartState {
  ShoppingCartDataStatus cartDataStatus;

  ShoppingCartState({required this.cartDataStatus});

  ShoppingCartState copyWith({ShoppingCartDataStatus? cartDataStatus}) {
    return ShoppingCartState(
      cartDataStatus: cartDataStatus ?? this.cartDataStatus,
    );
  }
}
