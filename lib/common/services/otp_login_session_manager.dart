class OtpLoginSession {
  final String mobileDigits;
  final DateTime requestedAt;

  static const int timeoutSeconds = 120;

  const OtpLoginSession({
    required this.mobileDigits,
    required this.requestedAt,
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

  void startSession(String mobileDigits) {
    _session = OtpLoginSession(
      mobileDigits: mobileDigits,
      requestedAt: DateTime.now(),
    );
  }

  void clearSession() {
    _session = null;
  }
}
