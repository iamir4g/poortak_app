import 'package:equatable/equatable.dart';

/// One Cafe Bazaar cart line ready for purchase + `payments/direct` fulfill.
class BazaarCheckoutItem extends Equatable {
  final String bazaarSku;
  final String productType;

  const BazaarCheckoutItem({
    required this.bazaarSku,
    required this.productType,
  });

  @override
  List<Object?> get props => [bazaarSku, productType];
}
