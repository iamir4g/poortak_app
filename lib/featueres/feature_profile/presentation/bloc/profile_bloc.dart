import 'package:bloc/bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_profile/data/models/login_with_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/request_otp_model.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/locator.dart';
import 'dart:developer';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  final PrefsOperator prefsOperator = locator<PrefsOperator>();

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<LoginWithOtpEvent>(_onLoginWithOtp);
  }

  void _onRequestOtp(RequestOtpEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await repository.callRequestOtp(event.mobile);
      log("_onRequestOtp - Response Type: ${response.runtimeType}");
      log("_onRequestOtp - Response: $response");

      if (response is DataSuccess) {
        log("_onRequestOtp - DataSuccess: ${response.data}");
        if (response.data != null) {
          log("_onRequestOtp - Emitting ProfileSuccessRequestOtp");
          emit(ProfileSuccessRequestOtp(response.data!));
        } else {
          log("_onRequestOtp - Emitting ProfileErrorRequestOtp (null data)");
          emit(ProfileErrorRequestOtp("Invalid response data"));
        }
      } else if (response is DataFailed) {
        log("_onRequestOtp - DataFailed: ${response.error}");
        log("_onRequestOtp - Emitting ProfileErrorRequestOtp");
        emit(
            ProfileErrorRequestOtp(response.error ?? "خطا در دریافت کد تایید"));
      }
    } catch (e) {
      log("_onRequestOtp - Error: $e");
      emit(ProfileErrorRequestOtp(e.toString()));
    }
  }

  void _onLoginWithOtp(
      LoginWithOtpEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await repository.callLoginWithOtp(event.otp);
      log("Login Response: ${response}");

      if (response is DataSuccess) {
        if (response.data != null) {
          final loginData = response.data!;
          await prefsOperator.saveUserData(
            loginData.data.result.accessToken,
            loginData.data.result.refreshToken,
            event.mobile,
            event.mobile,
          );
          emit(ProfileSuccessLogin(loginData));
        } else {
          emit(ProfileErrorLogin("Invalid response data"));
        }
      } else if (response is DataFailed) {
        emit(ProfileErrorLogin(response.error ?? "خطا در ورود"));
      }
    } catch (e) {
      log("Login Error: $e");
      emit(ProfileErrorLogin(e.toString()));
    }
  }
}
