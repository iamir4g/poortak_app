import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_params.dart';
import 'dart:developer';

class ProfileApiProvider {
  Dio dio;
  ProfileApiProvider({required this.dio});

  dynamic callRequestOtp(String phone) async {
    final response = await dio.post(
      "${Constants.baseUrl}auth/otp",
      data: {"phone": phone},
    );
    log(response.data.toString());
    return response;
  }

  dynamic callLoginWithOtp(String otp) async {
    final response = await dio.post(
      "${Constants.baseUrl}auth/otp/login",
      data: {"otp": otp},
    );
    return response;
  }

  dynamic callPaymentHistory({PaymentHistoryParams? params}) async {
    //payments
    final queryParams = params?.toQueryParams() ?? {};
    final response = await dio.get(
      "${Constants.baseUrl}payments",
      queryParameters: queryParams,
    );
    return response;
  }

  // dynamic callGetDownloadLink(String key) async {
  //   final response = await dio.get(
  //     "${Constants.baseUrl}storage/download/$key",
  //   );
  //   return response;
  // }

  // dynamic callGetDecryptKey(String fileId) async {
  //   final response = await dio.get(
  //     "${Constants.baseUrl}storage/key/$fileId",
  //   );
  //   return response;
  // }
}
