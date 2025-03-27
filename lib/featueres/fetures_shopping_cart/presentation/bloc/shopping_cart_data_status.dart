part of 'shopping_cart_cubit.dart';

@immutable
abstract class ShoppingCartDataStatus {}

class ShoppingCartDataInitial extends ShoppingCartDataStatus {}

class ShoppingCartDataLoading extends ShoppingCartDataStatus {}

class ShoppingCartDataCompleted extends ShoppingCartDataStatus {
  final dynamic data;
  ShoppingCartDataCompleted(this.data);
}

class ShoppingCartDataError extends ShoppingCartDataStatus {
  final String errorMessage;
  ShoppingCartDataError(this.errorMessage);
}
