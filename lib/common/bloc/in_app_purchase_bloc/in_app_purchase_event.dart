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
  /// Cafe Bazaar lines: SKU + catalog productType for `payments/direct`.
  final List<BazaarCheckoutItem> items;
  final String? payload;
  final String? referrerCode;

  const PurchaseProductsEvent({
    required this.items,
    this.payload,
    this.referrerCode,
  });

  @override
  List<Object?> get props => [items, payload, referrerCode];
}

class DisconnectInAppPurchaseEvent extends InAppPurchaseEvent {
  const DisconnectInAppPurchaseEvent();
}
