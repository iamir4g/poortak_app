class OtpLoginSession {
  final String mobileDigits;
  final DateTime requestedAt;
  final int otpLength;

  static const int timeoutSeconds = 120;
  static const int defaultOtpLength = 4;

  const OtpLoginSession({
    required this.mobileDigits,
    required this.requestedAt,
    this.otpLength = defaultOtpLength,
  });

  int get remainingSeconds {
    final elapsed = DateTime.now().difference(requestedAt).inSeconds;
    return (timeoutSeconds - elapsed).clamp(0, timeoutSeconds);
  }

  bool get canResend => remainingSeconds <= 0;
}

class OtpLoginSessionManager {
  static final OtpLoginSessionManager _instance =
      OtpLoginSessionManager._internal();

  factory OtpLoginSessionManager() => _instance;

  OtpLoginSessionManager._internal();

  OtpLoginSession? _session;

  bool get hasPendingOtp => _session != null;

  OtpLoginSession? get session => _session;

  String? get pendingMobileDigits => _session?.mobileDigits;

  void startSession(
    String mobileDigits, {
    int otpLength = OtpLoginSession.defaultOtpLength,
  }) {
    _session = OtpLoginSession(
      mobileDigits: mobileDigits,
      requestedAt: DateTime.now(),
      otpLength: otpLength,
    );
  }

  void clearSession() {
    _session = null;
  }
}
