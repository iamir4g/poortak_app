import 'package:dio/dio.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/data/models/login_with_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_modle.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_params.dart';
import 'package:poortak/featueres/feature_profile/data/models/request_otp_model.dart';
import 'dart:developer';

// import 'package:poortak/featueres/feature_profile/data/models/login_otp_model.dart';
class ProfileRepository {
  ProfileApiProvider profileApiProvider;

  ProfileRepository(this.profileApiProvider);

  Future<DataState<AuthRequestOtpModel>> callRequestOtp(String phone) async {
    try {
      Response response = await profileApiProvider.callRequestOtp(phone);
      log("Repository Response: ${response.data}");

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['ok'] == true) {
        final AuthRequestOtpModel requestOtpModel =
            AuthRequestOtpModel.fromJson(response.data);
        log("Repository Success - Parsed Model: ${requestOtpModel.data.result.otp}");
        return DataSuccess(requestOtpModel);
      } else {
        log("Repository Error - Status: ${response.statusCode}, Data: ${response.data}");
        return DataFailed(response.data['message'] ?? "خطا در دریافت کد تایید");
      }
    } catch (e) {
      log("Repository Error: $e");
      return DataFailed(e.toString());
    }
  }

  Future<DataState<AuthLoginOtpModel>> callLoginWithOtp(String otp) async {
    try {
      final response = await profileApiProvider.callLoginWithOtp(otp);
      log("Login Response: ${response.data}");

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['ok'] == true) {
        final AuthLoginOtpModel loginOtpModel =
            AuthLoginOtpModel.fromJson(response.data);
        log("Login Success - Parsed Model: ${loginOtpModel.data.result.accessToken}");
        return DataSuccess(loginOtpModel);
      } else {
        log("Login Error - Status: ${response.statusCode}, Data: ${response.data}");
        return DataFailed(response.data['message'] ?? "خطا در ورود");
      }
    } catch (e) {
      log("Login Error: $e");
      return DataFailed(e.toString());
    }
  }

  Future<DataState<PaymentHistoryList>> callPaymentHistory(
      {PaymentHistoryParams? params}) async {
    try {
      final response =
          await profileApiProvider.callPaymentHistory(params: params);
      log("Payment History Response: ${response.data}");
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['ok'] == true) {
        final PaymentHistoryList paymentHistoryList =
            PaymentHistoryList.fromJson(response.data);
        log("Payment History Success - Parsed Model: ${paymentHistoryList.data}");
        return DataSuccess(paymentHistoryList);
      } else {
        log("Payment History Error - Status: ${response.statusCode}, Data: ${response.data}");
        return DataFailed(
            response.data['message'] ?? "خطا در دریافت تاریخچه خرید");
      }
    } catch (e) {
      log("Payment History Error: $e");
      return DataFailed(e.toString());
    }
  }
}
