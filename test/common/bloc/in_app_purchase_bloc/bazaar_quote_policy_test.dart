import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/common/bloc/in_app_purchase_bloc/bazaar_quote_policy.dart';
import 'package:poortak/featueres/feature_shopping_cart/utils/cafebazaar_payment_errors.dart';

void main() {
  group('shouldRequestBazaarQuote', () {
    test('quotes when ownership deduction exists and points are 0', () {
      expect(
        shouldRequestBazaarQuote(
          pointsToSpend: 0,
          requireOwnershipQuote: true,
          alreadyOwned: false,
          isSingleSkuFirstItem: true,
        ),
        isTrue,
      );
    });

    test('quotes when spending points without a deduction', () {
      expect(
        shouldRequestBazaarQuote(
          pointsToSpend: 10,
          requireOwnershipQuote: false,
          alreadyOwned: false,
          isSingleSkuFirstItem: true,
        ),
        isTrue,
      );
    });

    test('skips quote when there is no deduction and no points', () {
      expect(
        shouldRequestBazaarQuote(
          pointsToSpend: 0,
          requireOwnershipQuote: false,
          alreadyOwned: false,
          isSingleSkuFirstItem: true,
        ),
        isFalse,
      );
    });

    test('skips quote when the SKU is already owned', () {
      expect(
        shouldRequestBazaarQuote(
          pointsToSpend: 0,
          requireOwnershipQuote: true,
          alreadyOwned: true,
          isSingleSkuFirstItem: true,
        ),
        isFalse,
      );
    });
  });

  group('shouldFallbackFullPriceOnDynamicPriceFailure', () {
    test('does not fall back to full price for ownership quotes', () {
      expect(
        shouldFallbackFullPriceOnDynamicPriceFailure(
          requireOwnershipQuote: true,
        ),
        isFalse,
      );
    });

    test('allows full-price fallback for points-only quotes', () {
      expect(
        shouldFallbackFullPriceOnDynamicPriceFailure(
          requireOwnershipQuote: false,
        ),
        isTrue,
      );
    });
  });

  group('shouldUseFreeCheckoutForQuoteFailure', () {
    test('routes unknown 422 with a deduction and no points to free checkout', () {
      expect(
        shouldUseFreeCheckoutForQuoteFailure(
          requireOwnershipQuote: true,
          pointsToSpend: 0,
          errorCode: null,
        ),
        isTrue,
      );
    });

    test('routes explicit freePurchase code to free checkout', () {
      expect(
        shouldUseFreeCheckoutForQuoteFailure(
          requireOwnershipQuote: true,
          pointsToSpend: 0,
          errorCode: CafeBazaarPaymentErrors.freePurchase,
        ),
        isTrue,
      );
    });

    test('does not treat item unavailable as a free checkout', () {
      expect(
        shouldUseFreeCheckoutForQuoteFailure(
          requireOwnershipQuote: true,
          pointsToSpend: 0,
          errorCode: CafeBazaarPaymentErrors.itemUnavailable,
        ),
        isFalse,
      );
    });
  });
}
