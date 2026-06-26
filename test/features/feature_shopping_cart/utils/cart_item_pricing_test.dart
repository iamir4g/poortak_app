import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/shopping_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/utils/cart_item_pricing.dart';

void main() {
  group('resolveCartItemPricing', () {
    test('returns plain pricing when source is missing', () {
      final pricing = resolveCartItemPricing(finalPriceToman: 75000);

      expect(pricing.finalPriceToman, 75000);
      expect(pricing.hasDiscount, isFalse);
    });

    test('uses source price and percent label for discounted items', () {
      final pricing = resolveCartItemPricing(
        finalPriceToman: 75000,
        source: {
          'price': '850000',
          'discountType': 'percent',
          'discountAmount': '10',
        },
      );

      expect(pricing.hasDiscount, isTrue);
      expect(pricing.originalPriceToman, 85000);
      expect(pricing.discountPercentLabel, '۱۰٪');
      expect(pricing.finalPriceToman, 75000);
    });

    test('applies percent discount when line price matches source price', () {
      final pricing = resolveCartItemPricing(
        finalPriceToman: 500000,
        source: {
          'price': '5000000',
          'discountType': 'Percent',
          'discountAmount': '10',
        },
      );

      expect(pricing.hasDiscount, isTrue);
      expect(pricing.originalPriceToman, 500000);
      expect(pricing.finalPriceToman, 450000);
      expect(pricing.discountPercentLabel, '۱۰٪');
    });
  });

  group('resolveCartTotals', () {
    test('derives discount from item pricing and grandTotal', () {
      final cart = ShoppingCart(
        subTotal: 450000,
        grandTotal: 450000,
        items: [
          ShoppingCartItem(
            title: 'مجموعه کامل سیاره آی نو',
            description: '',
            image: '',
            isLock: false,
            price: 500000,
            source: {
              'price': '5000000',
              'discountType': 'Percent',
              'discountAmount': '10',
            },
          ),
        ],
      );

      final totals = resolveCartTotals(cart);

      expect(totals.subTotal, 500000);
      expect(totals.payable, 450000);
      expect(totals.discount, 50000);
    });

    test('derives discount from subTotal and grandTotal when items empty', () {
      final cart = ShoppingCart(
        subTotal: 450000,
        grandTotal: 400000,
        items: const [],
      );

      final totals = resolveCartTotals(cart);

      expect(totals.subTotal, 450000);
      expect(totals.payable, 400000);
      expect(totals.discount, 50000);
    });

    test('falls back to item prices when totals are missing', () {
      final cart = ShoppingCart(
        items: [
          ShoppingCartItem(
            title: 'کتاب',
            description: '',
            image: '',
            isLock: false,
            price: 75000,
          ),
        ],
      );

      final totals = resolveCartTotals(cart);

      expect(totals.subTotal, 75000);
      expect(totals.payable, 75000);
      expect(totals.discount, 0);
    });
  });
}
