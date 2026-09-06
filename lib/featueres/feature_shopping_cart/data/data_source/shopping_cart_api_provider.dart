import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/services/auth_service.dart';
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
    log("💳 Checking out cart via API...");
    final response =
        await _authService.post("${Constants.baseUrl}cart/checkout");
    log("✅ Checkout Cart Response: ${response.data}");
    return response;
  }

  Future<Response> verifyBazaarPurchase({
    required String productId,
    required String purchaseToken,
    String? orderId,
    String? payload,
    String? originalJson,
    String? dataSignature,
  }) async {
    log("🛒 Verifying Cafe Bazaar purchase...");
    return _authService.post(
      "${Constants.baseUrl}payments/bazaar/verify",
      data: {
        "productId": productId,
        "purchaseToken": purchaseToken,
        "gateway": "BAZAAR",
        if (orderId != null && orderId.isNotEmpty) "orderId": orderId,
        if (payload != null && payload.isNotEmpty) "payload": payload,
        if (originalJson != null && originalJson.isNotEmpty)
          "originalJson": originalJson,
        if (dataSignature != null && dataSignature.isNotEmpty)
          "dataSignature": dataSignature,
      },
    );
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
