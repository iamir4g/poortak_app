import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/models/bazaar_checkout_item.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/bazaar_quote_model.dart';
import 'package:poortak/featueres/feature_shopping_cart/repositories/shopping_cart_repository.dart';
import 'package:poortak/featueres/feature_shopping_cart/utils/cafebazaar_payment_errors.dart';

class CartPointsDiscountState {
  final bool panelOpen;
  final bool eligible;
  final int pointsToSpend;
  final int maxPoints;
  final BazaarCheckoutItem? item;
  final BazaarQuoteData? quote;
  final bool isQuoting;
  final String? error;
  final String? errorCode;
  final bool serviceUnavailable;
  final int? pointValueInRials;

  const CartPointsDiscountState({
    this.panelOpen = false,
    this.eligible = false,
    this.pointsToSpend = 0,
    this.maxPoints = 0,
    this.item,
    this.quote,
    this.isQuoting = false,
    this.error,
    this.errorCode,
    this.serviceUnavailable = false,
    this.pointValueInRials,
  });

  bool get hasActiveDiscount =>
      pointsToSpend > 0 && quote != null && !serviceUnavailable;

  CartPointsDiscountState copyWith({
    bool? panelOpen,
    bool? eligible,
    int? pointsToSpend,
    int? maxPoints,
    BazaarCheckoutItem? item,
    bool clearItem = false,
    BazaarQuoteData? quote,
    bool clearQuote = false,
    bool? isQuoting,
    String? error,
    bool clearError = false,
    String? errorCode,
    bool clearErrorCode = false,
    bool? serviceUnavailable,
    int? pointValueInRials,
    bool clearPointValue = false,
  }) {
    return CartPointsDiscountState(
      panelOpen: panelOpen ?? this.panelOpen,
      eligible: eligible ?? this.eligible,
      pointsToSpend: pointsToSpend ?? this.pointsToSpend,
      maxPoints: maxPoints ?? this.maxPoints,
      item: clearItem ? null : (item ?? this.item),
      quote: clearQuote ? null : (quote ?? this.quote),
      isQuoting: isQuoting ?? this.isQuoting,
      error: clearError ? null : (error ?? this.error),
      errorCode: clearErrorCode ? null : (errorCode ?? this.errorCode),
      serviceUnavailable: serviceUnavailable ?? this.serviceUnavailable,
      pointValueInRials: clearPointValue
          ? null
          : (pointValueInRials ?? this.pointValueInRials),
    );
  }
}

class CartPointsDiscountCubit extends Cubit<CartPointsDiscountState> {
  final ShoppingCartRepository _repository;
  Timer? _debounce;
  int _quoteGeneration = 0;

  CartPointsDiscountCubit({required ShoppingCartRepository repository})
      : _repository = repository,
        super(const CartPointsDiscountState());

  void configureEligibility({
    required bool eligible,
    BazaarCheckoutItem? item,
    required int maxPoints,
  }) {
    final sameItem = state.item?.bazaarSku == item?.bazaarSku &&
        state.item?.productType == item?.productType;
    if (!eligible) {
      _debounce?.cancel();
      emit(const CartPointsDiscountState());
      return;
    }

    final clampedMax = maxPoints < 0 ? 0 : maxPoints;
    final points = sameItem
        ? state.pointsToSpend.clamp(0, clampedMax)
        : 0;
    emit(
      state.copyWith(
        eligible: true,
        item: item,
        maxPoints: clampedMax,
        pointsToSpend: points,
        clearQuote: !sameItem || points == 0,
        clearError: !sameItem,
        clearErrorCode: !sameItem,
        serviceUnavailable: sameItem ? state.serviceUnavailable : false,
        panelOpen: sameItem ? state.panelOpen : false,
      ),
    );
    if (sameItem && points > 0 && state.quote == null && !state.isQuoting) {
      _requestQuote(points);
    }
  }

  void togglePanel() {
    if (!state.eligible) return;
    emit(state.copyWith(panelOpen: !state.panelOpen));
  }

  /// One-tap: spend all remaining points and quote immediately (no debounce).
  Future<void> applyAllPoints() async {
    if (!state.eligible || state.maxPoints <= 0) return;
    _debounce?.cancel();
    final max = state.maxPoints;
    emit(
      state.copyWith(
        pointsToSpend: max,
        clearQuote: true,
        clearError: true,
        clearErrorCode: true,
        serviceUnavailable: false,
        isQuoting: true,
        panelOpen: false,
      ),
    );
    await _requestQuote(max);
  }

  /// Clear applied points / quote.
  void clearPoints() {
    _debounce?.cancel();
    _quoteGeneration++;
    emit(
      state.copyWith(
        pointsToSpend: 0,
        clearQuote: true,
        clearError: true,
        clearErrorCode: true,
        serviceUnavailable: false,
        isQuoting: false,
        panelOpen: false,
        clearPointValue: true,
      ),
    );
  }

  /// Toggle: apply all if none active, otherwise clear.
  Future<void> toggleApplyAllPoints() async {
    if (!state.eligible) return;
    if (state.hasActiveDiscount || state.pointsToSpend > 0 || state.isQuoting) {
      clearPoints();
      return;
    }
    await applyAllPoints();
  }

  void setPointsToSpend(int value) {
    if (!state.eligible) return;
    final clamped = value.clamp(0, state.maxPoints);
    emit(
      state.copyWith(
        pointsToSpend: clamped,
        clearQuote: clamped == 0,
        clearError: true,
        clearErrorCode: true,
        serviceUnavailable: false,
        isQuoting: clamped > 0,
      ),
    );
    _debounce?.cancel();
    if (clamped == 0) {
      emit(state.copyWith(isQuoting: false, clearQuote: true));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _requestQuote(clamped);
    });
  }

  Future<void> retryQuote() async {
    if (state.pointsToSpend <= 0) return;
    await _requestQuote(state.pointsToSpend);
  }

  Future<void> _requestQuote(int pointsToSpend) async {
    final item = state.item;
    if (item == null || pointsToSpend <= 0) {
      emit(state.copyWith(isQuoting: false, clearQuote: true));
      return;
    }

    final generation = ++_quoteGeneration;
    emit(
      state.copyWith(
        isQuoting: true,
        clearError: true,
        clearErrorCode: true,
        serviceUnavailable: false,
      ),
    );

    final result = await _repository.createBazaarQuote(
      productType: item.productType,
      bazaarSku: item.bazaarSku,
      pointsToSpend: pointsToSpend,
    );

    if (generation != _quoteGeneration || isClosed) return;

    if (result is DataSuccess<BazaarQuoteData> && result.data != null) {
      final quote = result.data!;
      emit(
        state.copyWith(
          isQuoting: false,
          quote: quote,
          pointsToSpend: quote.pointsSpent,
          pointValueInRials: quote.pointValueInRials,
          clearError: true,
          clearErrorCode: true,
          serviceUnavailable: false,
        ),
      );
      return;
    }

    final code = result.errorCode;
    if (code == CafeBazaarPaymentErrors.serviceUnavailable) {
      emit(
        state.copyWith(
          isQuoting: false,
          clearQuote: true,
          serviceUnavailable: true,
          error: result.error,
          errorCode: code,
          pointsToSpend: 0,
        ),
      );
      return;
    }

    if (code == CafeBazaarPaymentErrors.insufficientPoints) {
      final reduced = (state.pointsToSpend - 1).clamp(0, state.maxPoints);
      emit(
        state.copyWith(
          isQuoting: false,
          clearQuote: true,
          error: result.error,
          errorCode: code,
          pointsToSpend: reduced,
        ),
      );
      if (reduced > 0) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 400), () {
          _requestQuote(reduced);
        });
      }
      return;
    }

    emit(
      state.copyWith(
        isQuoting: false,
        clearQuote: true,
        error: result.error ?? 'خطا در محاسبه تخفیف امتیاز',
        errorCode: code,
      ),
    );
  }

  void reset() {
    _debounce?.cancel();
    _quoteGeneration++;
    emit(const CartPointsDiscountState());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
