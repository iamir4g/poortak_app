import 'package:equatable/equatable.dart';

class BazaarPurchaseResult extends Equatable {
  final String productId;
  final String purchaseToken;
  final String? orderId;
  final String? payload;
  final String? originalJson;
  final String? dataSignature;

  const BazaarPurchaseResult({
    required this.productId,
    required this.purchaseToken,
    this.orderId,
    this.payload,
    this.originalJson,
    this.dataSignature,
  });

  @override
  List<Object?> get props => [
        productId,
        purchaseToken,
        orderId,
        payload,
        originalJson,
        dataSignature,
      ];
}
