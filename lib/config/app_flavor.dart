import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Android Cafe Bazaar builds always use Poolakey IAP.
/// IPG / `cart/checkout` is only for iOS (or web).
///
/// Run the Android app with:
/// `flutter run --flavor bazaar`
class AppFlavor {
  static const String paymentChannel = String.fromEnvironment(
    'PAYMENT_CHANNEL',
    defaultValue: 'bazaar',
  );

  static const String appFlavor = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: '',
  );

  static bool get useBazaarIap {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }
}
