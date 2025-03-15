import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';

class ProfileApiProvider {
  Dio dio;
  ProfileApiProvider({required this.dio});

  dynamic callRequestOtp() async {
    final response = await dio.get("${Constants.baseUrl}/auth/otp");
  }

  dynamic callLoginWithOtp() async {
    final response = await dio.get("${Constants.baseUrl}/otp/login");
  }
}
