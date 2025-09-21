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
    // Only include fields that have values
    Map<String, dynamic> data = {};

    if (updateProfileModel.firstName.isNotEmpty) {
      data["firstName"] = updateProfileModel.firstName;
    }
    if (updateProfileModel.lastName.isNotEmpty) {
      data["lastName"] = updateProfileModel.lastName;
    }
    if (updateProfileModel.ageGroup.isNotEmpty) {
      data["ageGroup"] = updateProfileModel.ageGroup;
    }
    if (updateProfileModel.avatar.isNotEmpty) {
      data["avatar"] = updateProfileModel.avatar;
    }
    if (updateProfileModel.nationalCode.isNotEmpty) {
      data["nationalCode"] = updateProfileModel.nationalCode;
    }
    if (updateProfileModel.province.isNotEmpty) {
      data["province"] = updateProfileModel.province;
    }
    if (updateProfileModel.city.isNotEmpty) {
      data["city"] = updateProfileModel.city;
    }
    if (updateProfileModel.address.isNotEmpty) {
      data["address"] = updateProfileModel.address;
    }
    if (updateProfileModel.postalCode.isNotEmpty) {
      data["postalCode"] = updateProfileModel.postalCode;
    }
    if (updateProfileModel.birthdate.isNotEmpty) {
      data["birthdate"] = updateProfileModel.birthdate;
    }

    log("📤 Sending update data: $data");
    log("📊 Data keys: ${data.keys.toList()}");
    log("📊 Data values: ${data.values.toList()}");

    final response = await dio.patch(
      "${Constants.baseUrl}user/profile",
      data: data,
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
