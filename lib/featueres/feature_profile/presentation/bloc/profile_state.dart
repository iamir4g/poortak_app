import 'package:poortak/featueres/feature_profile/data/models/login_with_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/request_otp_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileErrorRequestOtp extends ProfileState {
  final String message;
  ProfileErrorRequestOtp(this.message);
}

class ProfileErrorLogin extends ProfileState {
  final String message;
  ProfileErrorLogin(this.message);
}

class ProfileSuccessRequestOtp extends ProfileState {
  final AuthRequestOtpModel data;
  ProfileSuccessRequestOtp(this.data);
}

class ProfileSuccessLogin extends ProfileState {
  final AuthLoginOtpModel data;
  ProfileSuccessLogin(this.data);
}
