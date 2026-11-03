bool shouldRequestBazaarQuote({
  required int pointsToSpend,
  required bool requireOwnershipQuote,
  required bool alreadyOwned,
  required bool isSingleSkuFirstItem,
}) {
  if (alreadyOwned || !isSingleSkuFirstItem) return false;
  return pointsToSpend > 0 || requireOwnershipQuote;
}

bool shouldFallbackFullPriceOnDynamicPriceFailure({
  required bool requireOwnershipQuote,
}) {
  return !requireOwnershipQuote;
}

bool shouldUseFreeCheckoutForQuoteFailure({
  required bool requireOwnershipQuote,
  required int pointsToSpend,
  required String? errorCode,
}) {
  if (!requireOwnershipQuote || pointsToSpend > 0) return false;
  if (errorCode == null || errorCode.isEmpty) return true;
  return errorCode == 'cafebazaarFreePurchase';
}
