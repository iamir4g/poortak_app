import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/locator.dart';

import 'user_points_total_event.dart';
import 'user_points_total_state.dart';

class UserPointsTotalBloc
    extends Bloc<UserPointsTotalEvent, UserPointsTotalState> {
  final ProfileRepository repository;
  final PrefsOperator prefsOperator;

  UserPointsTotalBloc({
    required this.repository,
    PrefsOperator? prefsOperator,
  })  : prefsOperator = prefsOperator ?? locator<PrefsOperator>(),
        super(UserPointsTotalInitial()) {
    on<LoadUserPointsTotalEvent>(_onLoadUserPointsTotal);
    on<RefreshUserPointsTotalEvent>(_onRefreshUserPointsTotal);
  }

  Future<void> _onLoadUserPointsTotal(
    LoadUserPointsTotalEvent event,
    Emitter<UserPointsTotalState> emit,
  ) async {
    if (!prefsOperator.isLoggedIn()) return;

    emit(UserPointsTotalLoading());

    try {
      log("🔄 Loading user points total");
      final response = await repository.callGetUserPointsTotal();

      if (response is DataSuccess && response.data != null) {
        log("✅ User points total loaded: remaining=${response.data!.data.remaining}, added=${response.data!.data.added}");
        emit(UserPointsTotalSuccess(data: response.data!.data));
      } else if (response is DataFailed) {
        log("❌ User points total failed: ${response.error}");
        emit(UserPointsTotalError(
            response.error ?? "خطا در دریافت امتیازها"));
      }
    } catch (e) {
      log("💥 User points total error: $e");
      emit(UserPointsTotalError(e.toString()));
    }
  }

  Future<void> _onRefreshUserPointsTotal(
    RefreshUserPointsTotalEvent event,
    Emitter<UserPointsTotalState> emit,
  ) async {
    if (!prefsOperator.isLoggedIn()) return;

    if (state is! UserPointsTotalSuccess) {
      emit(UserPointsTotalLoading());
    }

    try {
      log("🔄 Refreshing user points total");
      final response = await repository.callGetUserPointsTotal();

      if (response is DataSuccess && response.data != null) {
        log("✅ User points total refreshed");
        emit(UserPointsTotalSuccess(data: response.data!.data));
      } else if (response is DataFailed) {
        log("❌ User points total refresh failed: ${response.error}");
        emit(UserPointsTotalError(
            response.error ?? "خطا در دریافت امتیازها"));
      }
    } catch (e) {
      log("💥 User points total refresh error: $e");
      emit(UserPointsTotalError(e.toString()));
    }
  }
}
