import 'package:dio/dio.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/data/models/request_otp_model.dart';

class ProfileRepository {
  ProfileApiProvider profileApiProvider;

  ProfileRepository(this.profileApiProvider);

  Future<DataState<RequestOtpModel>> callRequestOtp() async {
    try {
      Response response = await profileApiProvider.callRequestOtp();
      // final response = await profileApiProvider.callRequestOtp();
      if (response.statusCode == 200) {
        final RequestOtpModel requestOtpModel =
            RequestOtpModel.fromJson(response.data);
        return DataSuccess(requestOtpModel);
      } else {
        return DataFailed(response.data['message']);
      }
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<dynamic>> callLoginWithOtp() async {
    try {
      final response = await profileApiProvider.callLoginWithOtp();
      return DataSuccess(response);
    } catch (e) {
      return DataFailed(e.toString());
    }
  }
}
