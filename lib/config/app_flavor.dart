import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Build-time payment channel.
///
/// Android Cafe Bazaar IAP:
/// `flutter run --flavor bazaar --dart-define=PAYMENT_CHANNEL=bazaar`
/// `flutter build apk --flavor bazaar --dart-define=PAYMENT_CHANNEL=bazaar --release`
///
/// iOS and default Android (`ipg`) builds keep the current IPG checkout.
class AppFlavor {
  static const String paymentChannel = String.fromEnvironment(
    'PAYMENT_CHANNEL',
    defaultValue: 'ipg',
  );

  static const String appFlavor = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: '',
  );

  static bool get useBazaarIap {
    if (kIsWeb) return false;
    try {
      if (!Platform.isAndroid) return false;
      return paymentChannel == 'bazaar' || appFlavor == 'bazaar';
    } catch (_) {
      return false;
    }
  }
}
