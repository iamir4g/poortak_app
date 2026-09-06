part of 'in_app_purchase_bloc.dart';

abstract class InAppPurchaseEvent extends Equatable {
  const InAppPurchaseEvent();

  @override
  List<Object?> get props => [];
}

class ConnectInAppPurchaseEvent extends InAppPurchaseEvent {
  const ConnectInAppPurchaseEvent();
}

class PurchaseProductsEvent extends InAppPurchaseEvent {
  final List<String> productIds;
  final String? payload;

  const PurchaseProductsEvent({
    required this.productIds,
    this.payload,
  });

  @override
  List<Object?> get props => [productIds, payload];
}

class DisconnectInAppPurchaseEvent extends InAppPurchaseEvent {
  const DisconnectInAppPurchaseEvent();
}
