import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:poortak/common/services/auth_navigation_manager.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_profile/data/models/login_with_otp_model.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required PrefsOperator prefsOperator,
    required Dio dio,
    required Dio refreshDio,
  })  : _prefsOperator = prefsOperator,
        _dio = dio,
        _refreshDio = refreshDio;

  final PrefsOperator _prefsOperator;
  final Dio _dio;
  final Dio _refreshDio;

  bool _isRefreshing = false;
  bool _isLoggingOut = false;
  Completer<void>? _refreshCompleter;

  static String get _refreshUrl => '${Constants.baseUrl}auth/refresh';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.extra['skipAuthRefresh'] == true) {
      await _handleSessionExpired();
      return handler.next(err);
    }

    final refreshToken = await _prefsOperator.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleSessionExpired();
      return handler.next(err);
    }

    try {
      if (_isRefreshing) {
        await _refreshCompleter!.future;
      } else {
        _isRefreshing = true;
        _refreshCompleter = Completer<void>();
        try {
          await _refreshAccessToken(refreshToken);
          _refreshCompleter!.complete();
        } catch (e) {
          if (!_refreshCompleter!.isCompleted) {
            _refreshCompleter!.completeError(e);
          }
          rethrow;
        } finally {
          _isRefreshing = false;
        }
      }

      final response = await _retryRequest(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      _refreshCompleter = null;
      await _handleSessionExpired();
      return handler.next(err);
    }
  }

  Future<void> _handleSessionExpired() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      if (!_prefsOperator.isLoggedIn()) {
        final refreshToken = await _prefsOperator.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) return;
      }

      log('🚪 Session expired - logging out');
      await _prefsOperator.logout();
      AuthNavigationManager().requestSessionExpiredLogout();
    } finally {
      _isLoggingOut = false;
    }
  }

  Future<void> _refreshAccessToken(String refreshToken) async {
    log('🔄 Attempting token refresh...');
    debugPrint('🌐 [REQUEST] POST $_refreshUrl');

    late final Response<dynamic> response;
    try {
      response = await _refreshDio.post(
        _refreshUrl,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      debugPrint('❌ [ERROR] ${e.response?.statusCode} $_refreshUrl');
      if (e.response?.data != null) {
        debugPrint('❌ [ERROR BODY] ${e.response?.data}');
      }
      rethrow;
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data is Map &&
        response.data['ok'] == true) {
      final model = AuthLoginOtpModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await _prefsOperator.updateTokens(
        model.data.result.accessToken,
        model.data.result.refreshToken,
      );
      log('✅ Token refresh successful');
      return;
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Token refresh failed',
    );
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _prefsOperator.getUserToken();
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      headers.remove('Authorization');
    }

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        extra: requestOptions.extra,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
      ),
    );
  }
}
