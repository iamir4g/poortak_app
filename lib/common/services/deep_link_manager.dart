import 'package:flutter/material.dart';
import 'package:poortak/featueres/feature_payment/presentation/screens/payment_result_screen.dart';

class DeepLinkManager {
  static final DeepLinkManager _instance = DeepLinkManager._internal();
  factory DeepLinkManager() => _instance;
  DeepLinkManager._internal();

  String? _pendingStatus;
  String? _pendingRef;
  bool _hasDeepLink = false;

  // Listeners for deep link events
  final List<VoidCallback> _listeners = [];

  String? get pendingStatus => _pendingStatus;
  String? get pendingRef => _pendingRef;
  bool get hasDeepLink => _hasDeepLink;

  void setDeepLinkData(String status, String? ref) {
    _pendingStatus = status;
    _pendingRef = ref;
    _hasDeepLink = true;
    debugPrint(
        "DeepLinkManager: Deep link data set - Status: $status, Ref: $ref");

    // Notify all listeners
    for (var listener in _listeners) {
      try {
        listener();
      } catch (e) {
        debugPrint("DeepLinkManager: Error notifying listener: $e");
      }
    }
  }

  void clearDeepLinkData() {
    _pendingStatus = null;
    _pendingRef = null;
    _hasDeepLink = false;
    debugPrint("DeepLinkManager: Deep link data cleared");

    // Notify all listeners
    for (var listener in _listeners) {
      try {
        listener();
      } catch (e) {
        debugPrint("DeepLinkManager: Error notifying listener: $e");
      }
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void navigateToPaymentResult(BuildContext context) {
    if (_pendingStatus != null) {
      debugPrint("DeepLinkManager: Navigating to PaymentResultScreen...");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(
            status: _pendingStatus!,
            ref: _pendingRef,
          ),
        ),
        (route) => false,
      );
    }
  }
}
