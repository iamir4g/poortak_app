import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_params.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'dart:developer';

import 'payment_history_event.dart';
import 'payment_history_state.dart';

class PaymentHistoryBloc
    extends Bloc<PaymentHistoryEvent, PaymentHistoryState> {
  final ProfileRepository repository;

  PaymentHistoryBloc({required this.repository})
      : super(PaymentHistoryInitial()) {
    on<LoadPaymentHistoryEvent>(_onLoadPaymentHistory);
    on<RefreshPaymentHistoryEvent>(_onRefreshPaymentHistory);
    on<LoadMorePaymentHistoryEvent>(_onLoadMorePaymentHistory);
    on<FilterPaymentHistoryEvent>(_onFilterPaymentHistory);
  }

  void _onLoadPaymentHistory(
    LoadPaymentHistoryEvent event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    emit(PaymentHistoryLoading());

    try {
      log("🔄 Loading payment history with params: ${event.params?.toQueryParams()}");

      final response =
          await repository.callPaymentHistory(params: event.params);

      if (response is DataSuccess) {
        if (response.data != null) {
          final paymentHistoryList = response.data!;

          if (paymentHistoryList.data?.isEmpty ?? true) {
            log("📭 No payment history found");
            emit(PaymentHistoryEmpty());
          } else {
            log("✅ Payment history loaded successfully: ${paymentHistoryList.data?.length ?? 0} items");
            emit(PaymentHistorySuccess(
              paymentHistoryList: paymentHistoryList,
              hasReachedMax: _hasReachedMax(paymentHistoryList),
              currentPage: event.params?.page ?? 1,
            ));
          }
        } else {
          log("❌ Payment history failed: Invalid response data");
          emit(PaymentHistoryError("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("❌ Payment history failed: ${response.error}");
        emit(PaymentHistoryError(
            response.error ?? "خطا در دریافت تاریخچه خرید"));
      }
    } catch (e) {
      log("💥 Payment history error: $e");
      emit(PaymentHistoryError(e.toString()));
    }
  }

  void _onRefreshPaymentHistory(
    RefreshPaymentHistoryEvent event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    // Keep current state but show refreshing indicator
    if (state is PaymentHistorySuccess) {
      emit(PaymentHistoryRefreshing());
    } else {
      emit(PaymentHistoryLoading());
    }

    try {
      log("🔄 Refreshing payment history with params: ${event.params?.toQueryParams()}");

      final response =
          await repository.callPaymentHistory(params: event.params);

      if (response is DataSuccess) {
        if (response.data != null) {
          final paymentHistoryList = response.data!;

          if (paymentHistoryList.data?.isEmpty ?? true) {
            log("📭 No payment history found after refresh");
            emit(PaymentHistoryEmpty());
          } else {
            log("✅ Payment history refreshed successfully: ${paymentHistoryList.data?.length ?? 0} items");
            emit(PaymentHistorySuccess(
              paymentHistoryList: paymentHistoryList,
              hasReachedMax: _hasReachedMax(paymentHistoryList),
              currentPage: event.params?.page ?? 1,
            ));
          }
        } else {
          log("❌ Payment history refresh failed: Invalid response data");
          emit(PaymentHistoryError("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("❌ Payment history refresh failed: ${response.error}");
        emit(PaymentHistoryError(
            response.error ?? "خطا در دریافت تاریخچه خرید"));
      }
    } catch (e) {
      log("💥 Payment history refresh error: $e");
      emit(PaymentHistoryError(e.toString()));
    }
  }

  void _onLoadMorePaymentHistory(
    LoadMorePaymentHistoryEvent event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    if (state is! PaymentHistorySuccess) return;

    final currentState = state as PaymentHistorySuccess;
    if (currentState.hasReachedMax) return;

    emit(PaymentHistoryLoadingMore());

    try {
      final nextPage = currentState.currentPage + 1;
      final params = event.params?.copyWith(page: nextPage) ??
          PaymentHistoryParams(page: nextPage);

      log("🔄 Loading more payment history - Page: $nextPage");

      final response = await repository.callPaymentHistory(params: params);

      if (response is DataSuccess) {
        if (response.data != null) {
          final newPaymentHistoryList = response.data!;

          // Combine existing data with new data
          final combinedData =
              List<Datum>.from(currentState.paymentHistoryList.data ?? [])
                ..addAll(newPaymentHistoryList.data ?? []);

          final combinedPaymentHistoryList = PaymentHistoryList(
            ok: newPaymentHistoryList.ok,
            meta: newPaymentHistoryList.meta,
            data: combinedData,
          );

          log("✅ More payment history loaded: ${newPaymentHistoryList.data?.length ?? 0} new items");
          emit(PaymentHistorySuccess(
            paymentHistoryList: combinedPaymentHistoryList,
            hasReachedMax: _hasReachedMax(newPaymentHistoryList),
            currentPage: nextPage,
          ));
        } else {
          log("❌ Load more payment history failed: Invalid response data");
          emit(PaymentHistoryError("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("❌ Load more payment history failed: ${response.error}");
        emit(PaymentHistoryError(
            response.error ?? "خطا در دریافت تاریخچه خرید"));
      }
    } catch (e) {
      log("💥 Load more payment history error: $e");
      emit(PaymentHistoryError(e.toString()));
    }
  }

  void _onFilterPaymentHistory(
    FilterPaymentHistoryEvent event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    emit(PaymentHistoryLoading());

    try {
      log("🔄 Filtering payment history with params: ${event.params.toQueryParams()}");

      final response =
          await repository.callPaymentHistory(params: event.params);

      if (response is DataSuccess) {
        if (response.data != null) {
          final paymentHistoryList = response.data!;

          if (paymentHistoryList.data?.isEmpty ?? true) {
            log("📭 No payment history found with current filters");
            emit(PaymentHistoryEmpty(
                message: "هیچ تراکنشی با فیلترهای انتخابی یافت نشد"));
          } else {
            log("✅ Payment history filtered successfully: ${paymentHistoryList.data?.length ?? 0} items");
            emit(PaymentHistorySuccess(
              paymentHistoryList: paymentHistoryList,
              hasReachedMax: _hasReachedMax(paymentHistoryList),
              currentPage: event.params.page,
            ));
          }
        } else {
          log("❌ Filter payment history failed: Invalid response data");
          emit(PaymentHistoryError("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("❌ Filter payment history failed: ${response.error}");
        emit(PaymentHistoryError(
            response.error ?? "خطا در دریافت تاریخچه خرید"));
      }
    } catch (e) {
      log("💥 Filter payment history error: $e");
      emit(PaymentHistoryError(e.toString()));
    }
  }

  bool _hasReachedMax(PaymentHistoryList paymentHistoryList) {
    // Check if we've reached the maximum number of items
    // This could be based on the meta count or a fixed limit
    return (paymentHistoryList.data?.length ?? 0) >=
        (paymentHistoryList.meta?.count ?? 0);
  }
}
