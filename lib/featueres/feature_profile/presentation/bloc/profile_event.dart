import 'package:poortak/featueres/feature_profile/data/models/update_profile_params.dart';

abstract class ProfileEvent {}

class RequestOtpEvent extends ProfileEvent {
  final String mobile;
  RequestOtpEvent({required this.mobile});
}

class LoginWithOtpEvent extends ProfileEvent {
  final String phone;
  final String otp;
  LoginWithOtpEvent({required this.phone, required this.otp});
}

class GetMeProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UpdateProfileParams updateProfileParams;
  UpdateProfileEvent({required this.updateProfileParams});
}
