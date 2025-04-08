import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';
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
}
