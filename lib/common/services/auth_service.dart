import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/locator.dart';

class AuthService {
  final Dio _dio;
  final PrefsOperator _prefsOperator;

  AuthService({required Dio dio})
      : _dio = dio,
        _prefsOperator = locator<PrefsOperator>();

  /// Makes an authenticated API request with automatic token handling
  ///
  /// This method:
  /// - Gets the user token from preferences
  /// - Sets the Authorization header
  /// - Handles only 401 responses by clearing the token and throwing UnauthorisedException
  /// - Re-throws other DioExceptions
  ///
  /// Usage:
  /// ```dart
  /// final response = await authService.makeAuthenticatedRequest(
  ///   () => dio.get('/api/endpoint')
  /// );
  /// ```
  Future<Response> makeAuthenticatedRequest(
      Future<Response> Function() request) async {
    log("🔐 Setting up authenticated request...");

    final token = await _prefsOperator.getUserToken();
    log("🔑 Retrieved token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}");

    if (token == null) {
      log("❌ No token found - user not logged in");
      throw UnauthorisedException(message: 'Please login to continue');
    }

    log("📤 Setting Authorization header with token");
    _dio.options.headers['Authorization'] = 'Bearer $token';
    log("✅ Authorization header set: Bearer ${token.substring(0, 20)}...");

    try {
      log("🌐 Making authenticated API request...");
      final response = await request();
      log("✅ API request successful");
      return response;
    } on DioException catch (e) {
      log("❌ DioException occurred during API request:");
      log("   Status code: ${e.response?.statusCode}");
      log("   Response data: ${e.response?.data}");
      log("   Error message: ${e.message}");

      if (e.response?.statusCode == 401) {
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

  /// Makes an authenticated GET request
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return makeAuthenticatedRequest(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  /// Makes an authenticated POST request
  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return makeAuthenticatedRequest(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  /// Makes an authenticated PUT request
  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return makeAuthenticatedRequest(
      () => _dio.put(path, data: data, queryParameters: queryParameters),
    );
  }

  /// Makes an authenticated PATCH request
  Future<Response> patch(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return makeAuthenticatedRequest(
      () => _dio.patch(path, data: data, queryParameters: queryParameters),
    );
  }

  /// Makes an authenticated DELETE request
  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return makeAuthenticatedRequest(
      () => _dio.delete(path, data: data, queryParameters: queryParameters),
    );
  }
}
