import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';

import 'prize_history_event.dart';
import 'prize_history_state.dart';

class PrizeHistoryBloc extends Bloc<PrizeHistoryEvent, PrizeHistoryState> {
  final ProfileRepository repository;

  PrizeHistoryBloc({required this.repository}) : super(PrizeHistoryInitial()) {
    on<LoadPrizeHistoryEvent>(_onLoadPrizeHistory);
    on<RefreshPrizeHistoryEvent>(_onRefreshPrizeHistory);
  }

  Future<void> _onLoadPrizeHistory(
    LoadPrizeHistoryEvent event,
    Emitter<PrizeHistoryState> emit,
  ) async {
    emit(PrizeHistoryLoading());

    try {
      log("🔄 Loading prize history");
      final response = await repository.callGetUserPointsHistory();

      if (response is DataSuccess && response.data != null) {
        final prizeHistoryResponse = response.data!;

        if (prizeHistoryResponse.data.isEmpty) {
          log("📭 No prize history found");
          emit(PrizeHistoryEmpty());
        } else {
          log("✅ Prize history loaded: ${prizeHistoryResponse.data.length} items");
          emit(PrizeHistorySuccess(prizeHistoryResponse: prizeHistoryResponse));
        }
      } else if (response is DataFailed) {
        log("❌ Prize history failed: ${response.error}");
        emit(PrizeHistoryError(
            response.error ?? "خطا در دریافت تاریخچه امتیاز"));
      }
    } catch (e) {
      log("💥 Prize history error: $e");
      emit(PrizeHistoryError(e.toString()));
    }
  }

  Future<void> _onRefreshPrizeHistory(
    RefreshPrizeHistoryEvent event,
    Emitter<PrizeHistoryState> emit,
  ) async {
    if (state is PrizeHistorySuccess) {
      emit(PrizeHistoryRefreshing());
    } else {
      emit(PrizeHistoryLoading());
    }

    try {
      log("🔄 Refreshing prize history");
      final response = await repository.callGetUserPointsHistory();

      if (response is DataSuccess && response.data != null) {
        final prizeHistoryResponse = response.data!;

        if (prizeHistoryResponse.data.isEmpty) {
          log("📭 No prize history found after refresh");
          emit(PrizeHistoryEmpty());
        } else {
          log("✅ Prize history refreshed: ${prizeHistoryResponse.data.length} items");
          emit(PrizeHistorySuccess(prizeHistoryResponse: prizeHistoryResponse));
        }
      } else if (response is DataFailed) {
        log("❌ Prize history refresh failed: ${response.error}");
        emit(PrizeHistoryError(
            response.error ?? "خطا در دریافت تاریخچه امتیاز"));
      }
    } catch (e) {
      log("💥 Prize history refresh error: $e");
      emit(PrizeHistoryError(e.toString()));
    }
  }
}
