part of 'in_app_purchase_bloc.dart';

abstract class InAppPurchaseState extends Equatable {
  const InAppPurchaseState();

  @override
  List<Object?> get props => [];
}

class InAppPurchaseInitial extends InAppPurchaseState {
  const InAppPurchaseInitial();
}

class InAppPurchaseUnavailable extends InAppPurchaseState {
  const InAppPurchaseUnavailable();
}

class InAppPurchaseConnecting extends InAppPurchaseState {
  const InAppPurchaseConnecting();
}

class InAppPurchaseConnected extends InAppPurchaseState {
  const InAppPurchaseConnected();
}

class InAppPurchasePurchasing extends InAppPurchaseState {
  final String productId;

  const InAppPurchasePurchasing(this.productId);

  @override
  List<Object?> get props => [productId];
}

class InAppPurchaseSuccess extends InAppPurchaseState {
  final List<BazaarPurchaseResult> purchases;

  const InAppPurchaseSuccess(this.purchases);

  @override
  List<Object?> get props => [purchases];
}

class InAppPurchaseError extends InAppPurchaseState {
  final String message;

  const InAppPurchaseError(this.message);

  @override
  List<Object?> get props => [message];
}
