import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:poortak/common/models/bazaar_purchase_result.dart';
import 'package:poortak/config/app_flavor.dart';
import 'package:poortak/config/env.dart';

class CafeBazaarPurchaseService {
  bool _connected = false;

  bool get isAvailable => AppFlavor.useBazaarIap;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (!isAvailable) {
      debugPrint('🛒 [Bazaar] IAP skipped (not Android bazaar build)');
      return;
    }
    if (_connected) return;

    final rsaKey = Env.cafeBazaarRsaKey;
    if (rsaKey.isEmpty) {
      throw StateError('کلید RSA بازار در فایل .env پیدا نشد');
    }

    final completer = Completer<void>();
    debugPrint('🛒 [Bazaar] Connecting to Cafe Bazaar billing...');
    try {
      await FlutterPoolakey.connect(
        rsaKey,
        onSucceed: () {
          _connected = true;
          debugPrint('🛒 [Bazaar] Connected');
          if (!completer.isCompleted) completer.complete();
        },
        onFailed: () {
          _connected = false;
          debugPrint('🛒 [Bazaar] Connection failed');
          if (!completer.isCompleted) {
            completer.completeError(
              StateError(
                'اتصال به کافه بازار ناموفق بود. برنامه بازار را نصب کنید.',
              ),
            );
          }
        },
        onDisconnected: () {
          _connected = false;
          debugPrint('🛒 [Bazaar] Disconnected');
        },
      );
      await completer.future.timeout(const Duration(seconds: 20));
    } catch (e) {
      _connected = false;
      debugPrint('🛒 [Bazaar] Connect error: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (!isAvailable) return;
    try {
      await FlutterPoolakey.disconnect();
    } catch (e) {
      debugPrint('🛒 [Bazaar] Disconnect error: $e');
    } finally {
      _connected = false;
    }
  }

  Future<void> ensureConnected() async {
    if (_connected) return;
    await connect();
    if (!_connected) {
      throw StateError(
        'اتصال به کافه بازار برقرار نشد. لطفا برنامه بازار را نصب کنید.',
      );
    }
  }

  Future<List<BazaarPurchaseResult>> getPurchasedProducts() async {
    await ensureConnected();
    final items = await FlutterPoolakey.getAllPurchasedProducts();
    return items.map(_mapPurchase).toList();
  }

  Future<BazaarPurchaseResult> purchase(
    String productId, {
    String payload = '',
  }) async {
    await ensureConnected();
    debugPrint('🛒 [Bazaar] purchase productId=$productId');
    final info = await FlutterPoolakey.purchase(
      productId,
      payload: payload,
    );
    final result = _mapPurchase(info);
    debugPrint(
      '🛒 [Bazaar] purchase success productId=${result.productId} '
      'token=${result.purchaseToken}',
    );
    return result;
  }

  BazaarPurchaseResult _mapPurchase(PurchaseInfo info) {
    return BazaarPurchaseResult(
      productId: info.productId,
      purchaseToken: info.purchaseToken,
      orderId: info.orderId,
      payload: info.payload,
      originalJson: info.originalJson,
      dataSignature: info.dataSignature,
    );
  }
}
