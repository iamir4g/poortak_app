import 'package:dio/dio.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/data/models/login_with_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_params.dart';
import 'package:poortak/featueres/feature_profile/data/models/request_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/me_profile_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/update_profile_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/update_profile_params.dart';
import 'package:poortak/featueres/feature_profile/data/models/user_points_total_model.dart';
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
    } on DioException catch (dioError) {
      log("Login DioException: $dioError");

      // Handle DioException with response data
      if (dioError.response != null) {
        final responseData = dioError.response!.data;
        log("DioException Response Data: $responseData");

        // Extract error message from response
        String errorMessage = "خطا در ورود";
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          }
        }

        // Check for specific invalid OTP error
        if (dioError.response!.statusCode == 400 &&
            errorMessage.toLowerCase().contains('invalid otp')) {
          errorMessage = "کد تایید اشتباه است. لطفاً کد صحیح را وارد کنید.";
        }

        return DataFailed(errorMessage);
      } else {
        // Handle DioException without response data
        return DataFailed("خطا در اتصال به سرور");
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

  Future<DataState<UpdateProfileModel>> callPutUserProfile(
      UpdateProfileParams updateProfileModel) async {
    try {
      final response =
          await profileApiProvider.callPutUserProfile(updateProfileModel);
      log("Update Profile Response: ${response.data}");
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['ok'] == true) {
        final UpdateProfileModel updateProfileModel =
            UpdateProfileModel.fromJson(response.data);
        log("Update Profile Success - Parsed Model: ${updateProfileModel}");
        return DataSuccess(updateProfileModel);
      } else {
        log("Update Profile Error - Status: ${response.statusCode}, Data: ${response.data}");
        return DataFailed(
            response.data['message'] ?? "خطا در بروزرسانی پروفایل");
      }
    } catch (e) {
      log("Update Profile Error: $e");
      return DataFailed(e.toString());
    }
  }

  Future<DataState<MeProfileModel>> callGetMeProfile() async {
    try {
      final response = await profileApiProvider.callGetMeProfile();
      log("Get Me Profile Response: ${response.data}");
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['ok'] == true) {
        final MeProfileModel meProfileModel =
            MeProfileModel.fromJson(response.data);
        log("Get Me Profile Success - Parsed Model: ${meProfileModel}");
        return DataSuccess(meProfileModel);
      } else {
        log("Get Me Profile Error - Status: ${response.statusCode}, Data: ${response.data}");
        return DataFailed(response.data['message'] ?? "خطا در دریافت پروفایل");
      }
    } catch (e) {
      log("Get Me Profile Error: $e");
      return DataFailed(e.toString());
    }
  }

  Future<DataState<UserPointsTotalModel>> callGetUserPointsTotal() async {
    try {
      final response = await profileApiProvider.callGetUserPointsTotal();
      log("User Points Total Response: ${response.data}");
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['ok'] == true) {
        final UserPointsTotalModel userPointsTotalModel =
            UserPointsTotalModel.fromJson(response.data);
        log("User Points Total Success - Parsed Model: remaining=${userPointsTotalModel.data.remaining}, added=${userPointsTotalModel.data.added}, deducted=${userPointsTotalModel.data.deducted}");
        return DataSuccess(userPointsTotalModel);
      } else {
        log("User Points Total Error - Status: ${response.statusCode}, Data: ${response.data}");
        return DataFailed(response.data['message'] ?? "خطا در دریافت امتیازها");
      }
    } catch (e) {
      log("User Points Total Error: $e");
      return DataFailed(e.toString());
    }
  }
}
