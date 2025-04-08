abstract class ProfileEvent {}

class RequestOtpEvent extends ProfileEvent {
  final String mobile;
  RequestOtpEvent({required this.mobile});
}

class LoginWithOtpEvent extends ProfileEvent {
  final String mobile;
  final String otp;
  LoginWithOtpEvent({required this.mobile, required this.otp});
}
