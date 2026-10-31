import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/iknow_package_pricing.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/iknow_summary_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/bazaar_quote_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/checkout_cart_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/get_cart_model.dart';

void main() {
  group('IKnowPackagePricing', () {
    test('parses package fields and owned items', () {
      final pricing = IKnowPackagePricing.fromJson({
        'packageId': 'settings-uuid',
        'basePrice': 20,
        'packageDiscount': 0,
        'priceAfterPackageDiscount': 20,
        'ownedItems': [
          {
            'type': 'IKnowBook',
            'itemId': 'book-uuid',
            'name': 'Book 1',
            'price': 5,
          },
        ],
        'ownedItemsTotal': 5,
        'appliedDeduction': 5,
        'payablePrice': 15,
      });

      expect(pricing.packageId, 'settings-uuid');
      expect(pricing.basePrice, 20);
      expect(pricing.appliedDeduction, 5);
      expect(pricing.payablePrice, 15);
      expect(pricing.hasOwnershipDeduction, isTrue);
      expect(pricing.isFree, isFalse);
      expect(pricing.ownedItems.single.name, 'Book 1');
    });

    test('tryParse returns null when package is missing', () {
      expect(IKnowPackagePricing.tryParse(null), isNull);
      expect(IKnowPackagePricing.tryParse('bad'), isNull);
    });
  });

  group('IKnowSummaryModel package mapping', () {
    test('maps json package to packageInfo', () {
      final model = IKnowSummaryModel.fromJson({
        'ok': true,
        'meta': {},
        'data': {
          'courses': [],
          'books': [],
          'settings': {
            'id': 'settings-uuid',
            'price': '20',
            'discountType': 'Amount',
            'discountAmount': '0',
          },
          'package': {
            'packageId': 'settings-uuid',
            'basePrice': 20,
            'packageDiscount': 0,
            'priceAfterPackageDiscount': 20,
            'ownedItems': [],
            'ownedItemsTotal': 0,
            'appliedDeduction': 0,
            'payablePrice': 0,
          },
        },
      });

      expect(model.data.packageInfo, isNotNull);
      expect(model.data.resolvedPackageId, 'settings-uuid');
      expect(model.data.isFreePackage, isTrue);
    });

    test('falls back to settings when package is missing', () {
      final model = IKnowSummaryModel.fromJson({
        'ok': true,
        'meta': {},
        'data': {
          'courses': [],
          'books': [],
          'settings': {
            'id': 'settings-uuid',
            'price': '200',
            'discountType': 'Amount',
            'discountAmount': '0',
          },
        },
      });

      expect(model.data.packageInfo, isNull);
      expect(model.data.resolvedPackageId, 'settings-uuid');
      expect(model.data.resolvedPayableToman, 20);
    });
  });

  group('GetCartModel pricing', () {
    test('parses numeric totals and package pricing', () {
      final model = GetCartModel.fromJson({
        'ok': true,
        'meta': {},
        'data': {
          'cart': {
            'id': 'cart-id',
            'userId': 'user-id',
            'createdAt': '2026-10-29T00:00:00.000Z',
            'updatedAt': '2026-10-29T00:00:00.000Z',
            'items': [
              {
                'id': 'item-id',
                'cartId': 'cart-id',
                'itemId': 'settings-uuid',
                'type': 'IKnow',
                'quantity': 1,
                'price': '20',
                'createdAt': '2026-10-29T00:00:00.000Z',
                'updatedAt': '2026-10-29T00:00:00.000Z',
                'source': {
                  'id': 'settings-uuid',
                  'price': '20',
                },
                'pricing': {
                  'packageId': 'settings-uuid',
                  'basePrice': 20,
                  'packageDiscount': 0,
                  'priceAfterPackageDiscount': 20,
                  'ownedItems': [],
                  'ownedItemsTotal': 5,
                  'appliedDeduction': 5,
                  'payablePrice': 15,
                },
              },
            ],
          },
          'subTotal': 15.0,
          'grandTotal': 15,
        },
      });

      expect(model.data.subTotal, 15);
      expect(model.data.grandTotal, 15);
      expect(model.data.cart.items!.single.price, '20');
      expect(model.data.cart.items!.single.pricing?.payablePrice, 15);
    });
  });

  group('CheckoutCartModel', () {
    test('parses free checkout with null url', () {
      final model = CheckoutCartModel.fromJson({
        'ok': true,
        'meta': {},
        'data': {
          'url': null,
          'paymentId': 'pay-1',
          'amount': 0,
          'isFree': true,
        },
      });

      expect(model.data, isNotNull);
      expect(model.data!.url, isNull);
      expect(model.data!.isFree, isTrue);
      expect(model.data!.amount, 0);
      expect(model.data!.shouldOpenGateway, isFalse);
    });

    test('parses paid checkout url without crashing on missing meta', () {
      final model = CheckoutCartModel.fromJson({
        'ok': true,
        'data': {
          'url': 'https://gateway.example',
          'paymentId': 'pay-2',
          'amount': 15,
          'isFree': false,
        },
      });

      expect(model.data!.url, 'https://gateway.example');
      expect(model.data!.shouldOpenGateway, isTrue);
    });
  });

  group('BazaarQuoteData ownership fields', () {
    test('parses ownershipDeduction without subtracting again', () {
      final quote = BazaarQuoteData.fromJson({
        'nonce': 'abc',
        'token': 'jwt',
        'expiresAt': '2026-10-29T00:00:00.000Z',
        'basePrice': 15,
        'pointsSpent': 0,
        'discountAmount': 0,
        'finalPrice': 15,
        'remainingPoints': 1000,
        'pointValueInRials': 1000,
        'ownershipDeduction': 5,
        'ownedItems': [
          {
            'type': 'IKnowBook',
            'itemId': 'book-uuid',
            'name': 'Book 1',
            'price': 5,
          },
        ],
      });

      expect(quote.basePrice, 15);
      expect(quote.finalPrice, 15);
      expect(quote.ownershipDeduction, 5);
      expect(quote.ownedItems.single.itemId, 'book-uuid');
    });
  });
}
