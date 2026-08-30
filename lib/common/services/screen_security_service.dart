import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Blocks screenshots and screen recording on supported platforms.
///
/// Android uses [WindowManager.LayoutParams.FLAG_SECURE].
/// iOS uses a secure-field overlay when native support is available.
class ScreenSecurityService {
  ScreenSecurityService._();

  static const MethodChannel _channel =
      MethodChannel('poortak.security.flutter.dev/channel');

  static Future<void> setEnabled(bool enable) async {
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod<void>(
        'setSecureFlag',
        {'enable': enable},
      );
    } catch (e) {
      debugPrint('ScreenSecurityService error: $e');
    }
  }
}
