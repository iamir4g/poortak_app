import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_shopping_cart/data/models/cart_enum.dart';
import 'package:poortak/locator.dart';

class ShoppingCartApiProvider {
  final Dio dio;
  final PrefsOperator _prefsOperator;

  ShoppingCartApiProvider({required this.dio})
      : _prefsOperator = locator<PrefsOperator>();

  Future<Response> _makeAuthenticatedRequest(
      Future<Response> Function() request) async {
    log("🔐 Setting up authenticated request...");

    final token = await _prefsOperator.getUserToken();
    log("🔑 Retrieved token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}");

    if (token == null) {
      log("❌ No token found - user not logged in");
      throw UnauthorisedException(message: 'Please login to continue');
    }

    log("📤 Setting Authorization header with token");
    dio.options.headers['Authorization'] = 'Bearer $token';
    log("✅ Authorization header set: Bearer ${token.substring(0, 20)}...");

    try {
      log("🌐 Making authenticated API request...");
      final response = await request();
      log("✅ API request successful");
      return response;
    } on DioException catch (e) {
      log("❌ API request failed with DioException");
      log("   Status code: ${e.response?.statusCode}");
      log("   Response data: ${e.response?.data}");
      log("   Error message: ${e.message}");

      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        log("🔐 Authentication failed - clearing token and throwing UnauthorisedException");
        // Clear token and throw unauthorized exception
        await _prefsOperator.logout();
        throw UnauthorisedException(
            message: 'Session expired. Please login again.');
      }
      rethrow;
    } catch (e) {
      log("💥 Unexpected error during API request: $e");
      rethrow;
    }
  }

  Future<Response> getCart() async {
    log("🛒 Getting cart from API...");
    final response = await _makeAuthenticatedRequest(
        () => dio.get("${Constants.baseUrl2}cart"));
    log("📦 Shopping Cart Response: ${response.data}");
    return response;
  }

  Future<Response> addToCart(CartType type, String itemId) async {
    log("➕ Adding item to cart via API...");
    log("   Type: ${type.name}");
    log("   ItemId: $itemId");
    log("   URL: ${Constants.baseUrl2}cart");

    final response = await _makeAuthenticatedRequest(() => dio.post(
        "${Constants.baseUrl2}cart",
        data: {"type": type.name, "itemId": itemId}));

    log("✅ Add to Cart Response: ${response.data}");
    return response;
  }

  Future<Response> clearCart() async {
    log("🗑️ Clearing cart via API...");
    final response = await _makeAuthenticatedRequest(
        () => dio.delete("${Constants.baseUrl2}cart"));
    log("✅ Clear Cart Response: ${response.data}");
    return response;
  }

  Future<Response> removeFromCart(String itemId) async {
    log("➖ Removing item from cart via API...");
    log("   ItemId: $itemId");
    final response = await _makeAuthenticatedRequest(
        () => dio.delete("${Constants.baseUrl2}cart/$itemId"));
    log("✅ Remove from Cart Response: ${response.data}");
    return response;
  }

  Future<Response> checkoutCart() async {
    log("💳 Checking out cart via API...");
    final response = await _makeAuthenticatedRequest(
        () => dio.post("${Constants.baseUrl2}cart/checkout"));
    log("✅ Checkout Cart Response: ${response.data}");
    return response;
  }
}
