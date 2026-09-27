import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/config/app_flavor.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/locator.dart';

class ShoppingCartApiProvider {
  final Dio dio;
  final AuthService _authService;

  ShoppingCartApiProvider({required this.dio})
      : _authService = locator<AuthService>();

  Future<Response> getCart() async {
    log("🛒 Getting cart from API...");
    final response = await _authService.get("${Constants.baseUrl}cart");
    log("📦 Shopping Cart Response: ${response.data}");
    return response;
  }

  Future<Response> addToCart(CartType type, String itemId) async {
    log("➕ Adding item to cart via API...");
    log("   Type: ${type.name}");
    log("   ItemId: $itemId");
    log("   URL: ${Constants.baseUrl}cart");

    final response = await _authService.post(
      "${Constants.baseUrl}cart",
      data: {"type": type.name, "itemId": itemId},
    );

    log("✅ Add to Cart Response: ${response.data}");
    return response;
  }

  Future<Response> clearCart() async {
    log("🗑️ Clearing cart via API...");
    final response = await _authService.delete("${Constants.baseUrl}cart");
    log("✅ Clear Cart Response: ${response.data}");
    return response;
  }

  Future<Response> removeFromCart(String itemId) async {
    log("➖ Removing item from cart via API...");
    log("   ItemId: $itemId");
    final response =
        await _authService.delete("${Constants.baseUrl}cart/$itemId");
    log("✅ Remove from Cart Response: ${response.data}");
    return response;
  }

  Future<Response> checkoutCart() async {
    if (AppFlavor.useBazaarIap) {
      throw StateError(
        'Android Bazaar builds must use FlutterPoolakey.purchase, not cart/checkout',
      );
    }
    log("💳 Checking out cart via API...");
    final response =
        await _authService.post("${Constants.baseUrl}cart/checkout");
    log("✅ Checkout Cart Response: ${response.data}");
    return response;
  }

  Future<Response> verifyBazaarPurchase({
    required String bazaarSku,
    required String productType,
    required String purchaseToken,
    String? referrerCode,
  }) async {
    final body = <String, dynamic>{
      "bazaarSku": bazaarSku,
      "productType": productType,
      "purchaseToken": purchaseToken,
      if (referrerCode != null && referrerCode.isNotEmpty)
        "referrerCode": referrerCode,
    };
    log("🛒 [Bazaar] verify request → payments/direct");
    log(
      "🛒 [Bazaar] verify body — "
      "bazaarSku=$bazaarSku "
      "productType=$productType "
      "purchaseToken=$purchaseToken "
      "referrerCode=$referrerCode",
    );
    log("🛒 [Bazaar] verify full body: $body");
    final response = await _authService.post(
      "${Constants.baseUrl}payments/direct",
      data: body,
    );
    log("🛒 [Bazaar] verify response status=${response.statusCode} "
        "data=${response.data}");
    return response;
  }

  Future<Response> applyReferrerCode(String referrerCode) async {
    log("🎟️ Applying referrer code via API...");
    final response = await _authService.post(
      "${Constants.baseUrl}cart/referrer",
      data: {"referrerCode": referrerCode},
    );
    log("✅ Apply Referrer Code Response: ${response.data}");
    return response;
  }
}
