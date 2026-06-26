import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/money_utils.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';

class CartItemPricing {
  final int finalPriceToman;
  final int? originalPriceToman;
  final String? discountPercentLabel;

  const CartItemPricing({
    required this.finalPriceToman,
    this.originalPriceToman,
    this.discountPercentLabel,
  });

  bool get hasDiscount =>
      originalPriceToman != null && originalPriceToman! > finalPriceToman;
}

int? _discountTomanFromSource(
  String? discountType,
  dynamic discountAmountRaw,
  int sourcePriceToman,
) {
  if (discountAmountRaw == null ||
      discountAmountRaw.toString().trim().isEmpty ||
      sourcePriceToman <= 0) {
    return null;
  }

  final normalizedType = discountType?.toLowerCase();
  if (normalizedType == 'percent') {
    final percent = MoneyUtils.parseRial(discountAmountRaw);
    if (percent <= 0 || percent >= 100) return null;
    return (sourcePriceToman * percent / 100).round();
  }

  if (normalizedType == 'fixed' || normalizedType == 'amount') {
    final fixedDiscount = MoneyUtils.parseRialToTomanInt(discountAmountRaw);
    return fixedDiscount > 0 ? fixedDiscount : null;
  }

  return null;
}

CartItemPricing resolveCartItemPricing({
  required int finalPriceToman,
  Map<String, dynamic>? source,
}) {
  if (source == null) {
    return CartItemPricing(finalPriceToman: finalPriceToman);
  }

  final discountType = source['discountType']?.toString();
  final discountAmountRaw = source['discountAmount'];
  final sourcePrice = MoneyUtils.parseRialToTomanInt(source['price']);
  final originalPrice = sourcePrice > 0 ? sourcePrice : finalPriceToman;
  final discountToman = _discountTomanFromSource(
    discountType,
    discountAmountRaw,
    originalPrice,
  );

  String? percentLabel;
  if (discountType?.toLowerCase() == 'percent' &&
      discountAmountRaw != null &&
      discountAmountRaw.toString().trim().isNotEmpty) {
    final percent = MoneyUtils.parseRial(discountAmountRaw);
    if (percent > 0) {
      percentLabel = '${toPersianDigits('$percent')}٪';
    }
  }

  final int displayFinal;
  if (sourcePrice > finalPriceToman) {
    // Server already sent the discounted line price.
    displayFinal = finalPriceToman;
  } else if (discountToman != null) {
    // Line price matches source price; apply discount from source metadata.
    displayFinal =
        (originalPrice - discountToman).clamp(0, originalPrice).toInt();
  } else {
    displayFinal = finalPriceToman > 0 ? finalPriceToman : originalPrice;
  }

  final hasDiscount = originalPrice > displayFinal;

  return CartItemPricing(
    finalPriceToman: displayFinal,
    originalPriceToman: hasDiscount ? originalPrice : null,
    discountPercentLabel: hasDiscount ? percentLabel : null,
  );
}

CartItemPricing resolveServerCartItemPricing(ShoppingCartItem item) {
  return resolveCartItemPricing(
    finalPriceToman: item.price,
    source: item.source,
  );
}

class CartTotals {
  final int subTotal;
  final int discount;
  final int payable;

  const CartTotals({
    required this.subTotal,
    required this.discount,
    required this.payable,
  });
}

CartTotals resolveCartTotals(ShoppingCart cart) {
  final payable = cart.grandTotal ??
      cart.items.fold<int>(
        0,
        (sum, item) => sum + resolveServerCartItemPricing(item).finalPriceToman,
      );

  final originalSubTotal = cart.items.fold<int>(
    0,
    (sum, item) {
      final pricing = resolveServerCartItemPricing(item);
      return sum + (pricing.originalPriceToman ?? pricing.finalPriceToman);
    },
  );

  final subTotal =
      originalSubTotal > 0 ? originalSubTotal : (cart.subTotal ?? payable);
  final discount = (subTotal - payable).clamp(0, subTotal);

  return CartTotals(
    subTotal: subTotal,
    discount: discount,
    payable: payable,
  );
}
