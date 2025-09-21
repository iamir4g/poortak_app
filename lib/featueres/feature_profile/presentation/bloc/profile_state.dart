import 'package:poortak/featueres/feature_profile/data/models/login_with_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/request_otp_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/me_profile_model.dart';
import 'package:poortak/featueres/feature_profile/data/models/update_profile_model.dart';

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

// Get Me Profile States
class ProfileErrorGetMe extends ProfileState {
  final String message;
  ProfileErrorGetMe(this.message);
}

class ProfileSuccessGetMe extends ProfileState {
  final MeProfileModel data;
  ProfileSuccessGetMe(this.data);
}

// Update Profile States
class ProfileErrorUpdate extends ProfileState {
  final String message;
  ProfileErrorUpdate(this.message);
}

class ProfileSuccessUpdate extends ProfileState {
  final UpdateProfileModel data;
  ProfileSuccessUpdate(this.data);
}
