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

  /// Points to spend on the first (single-SKU) line via quote + dynamicPriceToken.
  /// `0` / null → full-price path without quote/nonce.
  final int? pointsToSpend;

  /// Reuse an already-fetched quote from cart UI (avoids a second quote on Pay).
  final String? quoteNonce;
  final String? quoteToken;
  final DateTime? quoteExpiresAt;

  const PurchaseProductsEvent({
    required this.items,
    this.payload,
    this.referrerCode,
    this.pointsToSpend,
    this.quoteNonce,
    this.quoteToken,
    this.quoteExpiresAt,
  });

  @override
  List<Object?> get props => [
        items,
        payload,
        referrerCode,
        pointsToSpend,
        quoteNonce,
        quoteToken,
        quoteExpiresAt,
      ];
}

class DisconnectInAppPurchaseEvent extends InAppPurchaseEvent {
  const DisconnectInAppPurchaseEvent();
}
