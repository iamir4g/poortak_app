import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:poortak/common/models/bazaar_purchase_result.dart';
import 'package:poortak/common/models/bazaar_sku_details.dart';
import 'package:poortak/config/app_flavor.dart';
import 'package:poortak/config/env.dart';

class CafeBazaarPurchaseService {
  bool _connected = false;
  bool _reconnectScheduled = false;
  bool _intentionalDisconnect = false;

  bool get isAvailable => AppFlavor.useBazaarIap;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (!isAvailable) {
      debugPrint('🛒 [Bazaar] connect skipped (not Android bazaar build)');
      return;
    }
    if (_connected) {
      debugPrint('🛒 [Bazaar] connect skipped (already connected)');
      return;
    }

    final rsaKey = Env.cafeBazaarRsaKey;
    if (rsaKey.isEmpty) {
      debugPrint('🛒 [Bazaar] connect failed: RSA key missing in .env');
      throw StateError('کلید RSA بازار در فایل .env پیدا نشد');
    }

    _intentionalDisconnect = false;
    final completer = Completer<void>();
    debugPrint(
      '🛒 [Bazaar] connect start — rsaKeyLength=${rsaKey.length} '
      '(key not logged)',
    );
    try {
      await FlutterPoolakey.connect(
        rsaKey,
        onSucceed: () {
          _connected = true;
          debugPrint(
            '🛒 [Bazaar] connect onSucceed — '
            'no token/accountId from Poolakey connect',
          );
          if (!completer.isCompleted) completer.complete();
        },
        onFailed: () {
          _connected = false;
          debugPrint('🛒 [Bazaar] connect onFailed');
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
          debugPrint('🛒 [Bazaar] connect onDisconnected');
          _scheduleReconnect();
        },
      );
      await completer.future.timeout(const Duration(seconds: 20));
      debugPrint('🛒 [Bazaar] connect completed — connected=$_connected');
    } catch (e, st) {
      _connected = false;
      debugPrint('🛒 [Bazaar] connect error: $e');
      debugPrint('🛒 [Bazaar] connect stack: $st');
      rethrow;
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect || !isAvailable || _reconnectScheduled) {
      return;
    }
    _reconnectScheduled = true;
    debugPrint('🛒 [Bazaar] scheduling reconnect after disconnect');
    Future<void>.delayed(const Duration(seconds: 1), () async {
      _reconnectScheduled = false;
      if (_intentionalDisconnect || _connected || !isAvailable) {
        return;
      }
      try {
        debugPrint('🛒 [Bazaar] reconnect attempt after disconnect');
        await connect();
      } catch (e, st) {
        debugPrint('🛒 [Bazaar] reconnect after disconnect failed: $e');
        debugPrint('🛒 [Bazaar] reconnect stack: $st');
      }
    });
  }

  Future<void> disconnect() async {
    if (!isAvailable) {
      debugPrint('🛒 [Bazaar] disconnect skipped (not available)');
      return;
    }
    _intentionalDisconnect = true;
    _reconnectScheduled = false;
    debugPrint('🛒 [Bazaar] disconnect start');
    try {
      await FlutterPoolakey.disconnect();
      debugPrint('🛒 [Bazaar] disconnect done');
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] disconnect error: $e');
      debugPrint('🛒 [Bazaar] disconnect stack: $st');
    } finally {
      _connected = false;
    }
  }

  Future<void> ensureConnected() async {
    if (_connected) {
      debugPrint('🛒 [Bazaar] ensureConnected — already connected');
      return;
    }
    debugPrint('🛒 [Bazaar] ensureConnected — reconnecting...');
    await connect();
    if (!_connected) {
      debugPrint('🛒 [Bazaar] ensureConnected failed — still not connected');
      throw StateError(
        'اتصال به کافه بازار برقرار نشد. لطفا برنامه بازار را نصب کنید.',
      );
    }
    debugPrint('🛒 [Bazaar] ensureConnected — connected ok');
  }

  Future<List<BazaarPurchaseResult>> getPurchasedProducts() async {
    debugPrint('🛒 [Bazaar] getPurchasedProducts start');
    await ensureConnected();
    try {
      final items = await FlutterPoolakey.getAllPurchasedProducts();
      debugPrint(
        '🛒 [Bazaar] getPurchasedProducts count=${items.length}',
      );
      for (var i = 0; i < items.length; i++) {
        _logPurchaseInfo('getPurchasedProducts[$i]', items[i]);
      }
      return items.map(_mapPurchase).toList();
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] getPurchasedProducts error: $e');
      debugPrint('🛒 [Bazaar] getPurchasedProducts stack: $st');
      rethrow;
    }
  }

  Future<List<BazaarPurchaseResult>> getSubscribedProducts() async {
    debugPrint('🛒 [Bazaar] getSubscribedProducts start');
    await ensureConnected();
    try {
      final items = await FlutterPoolakey.getAllSubscribedProducts();
      debugPrint(
        '🛒 [Bazaar] getSubscribedProducts count=${items.length}',
      );
      for (var i = 0; i < items.length; i++) {
        _logPurchaseInfo('getSubscribedProducts[$i]', items[i]);
      }
      return items.map(_mapPurchase).toList();
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] getSubscribedProducts error: $e');
      debugPrint('🛒 [Bazaar] getSubscribedProducts stack: $st');
      rethrow;
    }
  }

  Future<BazaarPurchaseResult?> queryPurchasedProduct(String productId) async {
    debugPrint('🛒 [Bazaar] queryPurchasedProduct — productId=$productId');
    await ensureConnected();
    try {
      final info = await FlutterPoolakey.queryPurchasedProduct(productId);
      if (info == null) {
        debugPrint(
          '🛒 [Bazaar] queryPurchasedProduct — not found: $productId',
        );
        return null;
      }
      _logPurchaseInfo('queryPurchasedProduct', info);
      return _mapPurchase(info);
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] queryPurchasedProduct error: $e');
      debugPrint('🛒 [Bazaar] queryPurchasedProduct stack: $st');
      rethrow;
    }
  }

  Future<BazaarPurchaseResult?> querySubscribedProduct(String productId) async {
    debugPrint('🛒 [Bazaar] querySubscribedProduct — productId=$productId');
    await ensureConnected();
    try {
      final info = await FlutterPoolakey.querySubscribedProduct(productId);
      if (info == null) {
        debugPrint(
          '🛒 [Bazaar] querySubscribedProduct — not found: $productId',
        );
        return null;
      }
      _logPurchaseInfo('querySubscribedProduct', info);
      return _mapPurchase(info);
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] querySubscribedProduct error: $e');
      debugPrint('🛒 [Bazaar] querySubscribedProduct stack: $st');
      rethrow;
    }
  }

  Future<BazaarPurchaseResult> purchase(
    String sku, {
    String payload = '',
    String dynamicPriceToken = '',
  }) async {
    await ensureConnected();
    debugPrint(
      '🛒 [Bazaar] purchase start — sku=$sku payload=$payload '
      'dynamicPriceToken=${dynamicPriceToken.isEmpty ? "(none)" : "(set)"}',
    );
    try {
      final info = await FlutterPoolakey.purchase(
        sku,
        payload: payload,
        dynamicPriceToken: dynamicPriceToken,
      );
      _logPurchaseInfo('purchase result', info);
      final result = _mapPurchase(info);
      debugPrint(
        '🛒 [Bazaar] purchase success — '
        'productId=${result.productId} '
        'purchaseToken=${result.purchaseToken} '
        'orderId=${result.orderId}',
      );
      return result;
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] purchase error sku=$sku: $e');
      debugPrint('🛒 [Bazaar] purchase stack: $st');
      rethrow;
    }
  }

  Future<BazaarPurchaseResult> subscribe(
    String sku, {
    String payload = '',
    String dynamicPriceToken = '',
  }) async {
    await ensureConnected();
    debugPrint(
      '🛒 [Bazaar] subscribe start — sku=$sku payload=$payload '
      'dynamicPriceToken=${dynamicPriceToken.isEmpty ? "(none)" : "(set)"}',
    );
    try {
      final info = await FlutterPoolakey.subscribe(
        sku,
        payload: payload,
        dynamicPriceToken: dynamicPriceToken,
      );
      _logPurchaseInfo('subscribe result', info);
      final result = _mapPurchase(info);
      debugPrint(
        '🛒 [Bazaar] subscribe success — '
        'productId=${result.productId} '
        'purchaseToken=${result.purchaseToken} '
        'orderId=${result.orderId}',
      );
      return result;
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] subscribe error sku=$sku: $e');
      debugPrint('🛒 [Bazaar] subscribe stack: $st');
      rethrow;
    }
  }

  /// Consumes a consumable purchase so the user can buy the same SKU again.
  /// Do not call for permanent unlocks (courses/books/bundles).
  Future<bool> consume(String purchaseToken) async {
    await ensureConnected();
    debugPrint(
      '🛒 [Bazaar] consume start — purchaseToken=$purchaseToken',
    );
    try {
      final ok = await FlutterPoolakey.consume(purchaseToken);
      debugPrint('🛒 [Bazaar] consume result=$ok');
      return ok;
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] consume error: $e');
      debugPrint('🛒 [Bazaar] consume stack: $st');
      rethrow;
    }
  }

  Future<List<BazaarSkuDetails>> getInAppSkuDetails(
    List<String> skuIds,
  ) async {
    debugPrint(
      '🛒 [Bazaar] getInAppSkuDetails start — skuIds=$skuIds',
    );
    await ensureConnected();
    try {
      final items = await FlutterPoolakey.getInAppSkuDetails(skuIds);
      debugPrint('🛒 [Bazaar] getInAppSkuDetails count=${items.length}');
      for (var i = 0; i < items.length; i++) {
        _logSkuDetails('getInAppSkuDetails[$i]', items[i]);
      }
      return items.map(_mapSkuDetails).toList();
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] getInAppSkuDetails error: $e');
      debugPrint('🛒 [Bazaar] getInAppSkuDetails stack: $st');
      rethrow;
    }
  }

  Future<List<BazaarSkuDetails>> getSubscriptionSkuDetails(
    List<String> skuIds,
  ) async {
    debugPrint(
      '🛒 [Bazaar] getSubscriptionSkuDetails start — skuIds=$skuIds',
    );
    await ensureConnected();
    try {
      final items = await FlutterPoolakey.getSubscriptionSkuDetails(skuIds);
      debugPrint(
        '🛒 [Bazaar] getSubscriptionSkuDetails count=${items.length}',
      );
      for (var i = 0; i < items.length; i++) {
        _logSkuDetails('getSubscriptionSkuDetails[$i]', items[i]);
      }
      return items.map(_mapSkuDetails).toList();
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] getSubscriptionSkuDetails error: $e');
      debugPrint('🛒 [Bazaar] getSubscriptionSkuDetails stack: $st');
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> checkTrialSubscription() async {
    debugPrint('🛒 [Bazaar] checkTrialSubscription start');
    await ensureConnected();
    try {
      final result = await FlutterPoolakey.checkTrialSubscription();
      debugPrint('🛒 [Bazaar] checkTrialSubscription result=$result');
      return result;
    } catch (e, st) {
      debugPrint('🛒 [Bazaar] checkTrialSubscription error: $e');
      debugPrint('🛒 [Bazaar] checkTrialSubscription stack: $st');
      rethrow;
    }
  }

  void _logPurchaseInfo(String label, PurchaseInfo info) {
    debugPrint(
      '🛒 [Bazaar] $label —\n'
      '  orderId: ${info.orderId}\n'
      '  purchaseToken: ${info.purchaseToken}\n'
      '  productId: ${info.productId}\n'
      '  payload: ${info.payload}\n'
      '  packageName: ${info.packageName}\n'
      '  purchaseState: ${info.purchaseState}\n'
      '  purchaseTime: ${info.purchaseTime}\n'
      '  originalJson: ${info.originalJson}\n'
      '  dataSignature: ${info.dataSignature}',
    );
  }

  void _logSkuDetails(String label, SkuDetails details) {
    debugPrint(
      '🛒 [Bazaar] $label —\n'
      '  sku: ${details.sku}\n'
      '  type: ${details.type}\n'
      '  price: ${details.price}\n'
      '  title: ${details.title}\n'
      '  description: ${details.description}',
    );
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

  BazaarSkuDetails _mapSkuDetails(SkuDetails details) {
    return BazaarSkuDetails(
      sku: details.sku,
      type: details.type,
      price: details.price,
      title: details.title,
      description: details.description,
    );
  }
}
