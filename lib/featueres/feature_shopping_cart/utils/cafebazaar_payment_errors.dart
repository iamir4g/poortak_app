import 'package:flutter/services.dart';

/// CafeBazaar / points-discount API error codes from the Poortak backend.
class CafeBazaarPaymentErrors {
  CafeBazaarPaymentErrors._();

  static const insufficientPoints = 'cafebazaarInsufficientPoints';
  static const serviceUnavailable = 'cafebazaarServiceUnavailable';
  static const itemUnavailable = 'cafebazaarItemUnavailable';
  static const itemNotPublished = 'itemIsNotPublished';
  static const dynamicPriceInvalid = 'cafebazaarDynamicPriceInvalid';
  static const tokenAlreadyUsed = 'cafebazaarTokenAlreadyUsed';
  static const verificationFailed = 'cafebazaarVerificationFailed';

  static const knownCodes = <String>{
    insufficientPoints,
    serviceUnavailable,
    itemUnavailable,
    itemNotPublished,
    dynamicPriceInvalid,
    tokenAlreadyUsed,
    verificationFailed,
  };

  static String? extractCode(dynamic responseData) {
    if (responseData is! Map) return null;
    final map = Map<String, dynamic>.from(responseData);

    for (final key in ['error', 'code', 'errorCode']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        final trimmed = value.trim();
        if (knownCodes.contains(trimmed)) return trimmed;
      }
    }

    final message = map['message'];
    if (message is String) {
      for (final code in knownCodes) {
        if (message.contains(code)) return code;
      }
    }

    return null;
  }

  static String extractMessage(
    dynamic responseData, {
    required String fallback,
  }) {
    if (responseData is Map) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final error = responseData['error'];
      if (error is String &&
          error.trim().isNotEmpty &&
          !knownCodes.contains(error.trim())) {
        return error.trim();
      }
    }
    return fallback;
  }

  static String userMessageFor(String? code, {String? fallback}) {
    switch (code) {
      case insufficientPoints:
        return 'امتیاز کافی نیست؛ مقدار کمتری انتخاب کنید';
      case serviceUnavailable:
        return 'سرویس تخفیف امتیاز در دسترس نیست؛ خرید با قیمت کامل ادامه می‌یابد';
      case itemUnavailable:
      case itemNotPublished:
        return 'این محصول برای خرید در بازار در دسترس نیست';
      case dynamicPriceInvalid:
        return 'تخفیف امتیاز منقضی شده است؛ دوباره محاسبه کنید';
      case tokenAlreadyUsed:
        return 'این خرید قبلاً ثبت شده است';
      case verificationFailed:
        return 'تأیید خرید از بازار ناموفق بود';
      default:
        return fallback ?? 'خطا در پرداخت بازار';
    }
  }

  /// Poolakey reports unsupported dynamic pricing via PlatformException message.
  static bool isDynamicPriceUnsupported(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('dynamicpricenotsupported') ||
        text.contains('dynamic price not supported') ||
        text.contains('dynamicpricenotsupportedexception');
  }

  /// Bazaar rejected the purchase Intent / dynamic price token
  /// (e.g. «اطلاعات ارسال برنامه برای پرداخت نامعتبر است»).
  static bool isDynamicPriceRejectedByBazaar(Object error) {
    final text = error.toString().toLowerCase();
    final code = error is PlatformException
        ? (error.code).toLowerCase()
        : '';
    final message = error is PlatformException
        ? (error.message ?? '').toLowerCase()
        : text;

    if (code.contains('failed_to_begin_flow') ||
        code.contains('purchase_failed')) {
      return true;
    }
    return text.contains('نامعتبر') ||
        message.contains('نامعتبر') ||
        text.contains('invalid') ||
        message.contains('invalid') ||
        text.contains('failed_to_begin_flow') ||
        message.contains('failed_to_begin_flow');
  }

  /// When a dynamicPriceToken was sent and Bazaar cannot apply it, fall back
  /// to a full-price purchase (no token / no nonce).
  static bool shouldFallbackFullPrice(Object error) {
    return isDynamicPriceUnsupported(error) ||
        isDynamicPriceRejectedByBazaar(error);
  }
}

