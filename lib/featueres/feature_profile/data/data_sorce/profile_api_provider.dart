import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_profile/data/models/payment_history_params.dart';
import 'package:poortak/featueres/feature_profile/data/models/update_profile_params.dart';
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

  ///api/v1/user/profile

  dynamic callPutUserProfile(UpdateProfileParams updateProfileModel) async {
    final response = await dio.put(
      "${Constants.baseUrl}user/profile",
      data: {
        "firstName": updateProfileModel.firstName,
        "lastName": updateProfileModel.lastName,
        "ageGroup": updateProfileModel.ageGroup,
        "avatar": updateProfileModel.avatar,
        "nationalCode": updateProfileModel.nationalCode,
        "province": updateProfileModel.province,
        "city": updateProfileModel.city,
        "address": updateProfileModel.address,
        "postalCode": updateProfileModel.postalCode,
        "birthdate": updateProfileModel.birthdate,
      },
    );
    return response;
  }

  dynamic callGetMeProfile() async {
    final response = await dio.get(
      "${Constants.baseUrl}auth/me",
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
