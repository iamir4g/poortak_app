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
    final token = await _prefsOperator.getUserToken();
    if (token == null) {
      throw UnauthorisedException(message: 'Please login to continue');
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        // Clear token and throw unauthorized exception
        await _prefsOperator.logout();
        throw UnauthorisedException(
            message: 'Session expired. Please login again.');
      }
      rethrow;
    }
  }

  Future<Response> getCart() async {
    final response = await _makeAuthenticatedRequest(
        () => dio.get("${Constants.baseUrl}/cart"));
    log("Shopping Cart Response: ${response.data}");
    return response;
  }
}
