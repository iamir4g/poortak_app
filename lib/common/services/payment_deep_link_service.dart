import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentDeepLinkData {
  final int ok;
  final String? ref;

  const PaymentDeepLinkData({
    required this.ok,
    this.ref,
  });
}

/// Handles payment return deep links (`return://poortak?ok=...&ref=...`).
///
/// Android may replay the same launch intent on every cold start; this service
/// ensures each payment ref is only handled once.
class PaymentDeepLinkService {
  static const _handledRefKey = 'handled_payment_deep_link_ref';

  final SharedPreferences _prefs;
  final Set<String> _handledInSession = {};
  PaymentDeepLinkData? _pendingResult;

  PaymentDeepLinkService({required PrefsOperator prefsOperator})
      : _prefs = prefsOperator.sharedPreferences;

  PaymentDeepLinkData? get pendingResult => _pendingResult;

  PaymentDeepLinkData? takePendingResult() {
    final result = _pendingResult;
    _pendingResult = null;
    return result;
  }

  bool isPaymentReturnUri(Uri uri) {
    return uri.scheme == 'return' &&
        uri.host == 'poortak' &&
        uri.queryParameters.containsKey('ok');
  }

  String _linkKey(Uri uri) {
    final ref = uri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      return ref;
    }
    return uri.toString();
  }

  /// Returns payment data when the link should be handled; null if stale/duplicate.
  ///
  /// When [defer] is true (cold start from splash), the result is stored for
  /// [MainWrapper] to present. Otherwise the caller should navigate immediately.
  Future<PaymentDeepLinkData?> tryConsume(
    Uri uri, {
    bool defer = false,
  }) async {
    if (!isPaymentReturnUri(uri)) {
      return null;
    }

    final key = _linkKey(uri);
    if (_handledInSession.contains(key)) {
      return null;
    }

    final previouslyHandled = _prefs.getString(_handledRefKey);
    if (previouslyHandled == key) {
      return null;
    }

    final okParam = uri.queryParameters['ok'];
    if (okParam == null) {
      return null;
    }

    final data = PaymentDeepLinkData(
      ok: int.parse(okParam),
      ref: uri.queryParameters['ref'],
    );

    _handledInSession.add(key);
    await _prefs.setString(_handledRefKey, key);
    if (defer) {
      _pendingResult = data;
    }
    return data;
  }
}
