import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/models/decerypt_key_response.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';
// import '../models/storage_file.dart';
import '../models/download_url_response.dart';

/// Which authenticated download API to use for full (non-public) files.
enum ContentDownloadSource { iknow, kavoosh }

class StorageService {
  final Dio dio;

  StorageService({required this.dio});

  String _extractDownloadUrl(dynamic responseData) {
    // Response structure: {ok: true, meta: {}, data: "url"}
    if (responseData is Map) {
      final data = Map<String, dynamic>.from(responseData);

      if (data['data'] is String) {
        final url = data['data'] as String;
        log("Extracted URL: $url");
        return url;
      }

      if (data['url'] is String) {
        return data['url'] as String;
      }
    }

    return responseData.toString();
  }

  // For course video downloads - uses new API
  Future<String> callDownloadCourseVideo(String courseId) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}iknow/courses/$courseId/download",
      );

      log("Course Video Download URL Response: ${response.data}");
      return _extractDownloadUrl(response.data);
    } catch (e) {
      log("Error calling callDownloadCourseVideo: $e");
      rethrow;
    }
  }

  /// Kavoosh video lesson download (requires course + lesson access).
  Future<String> callDownloadVideoCourseLesson({
    required String courseId,
    required String lessonId,
  }) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}video-courses/$courseId/lessons/$lessonId/download",
      );

      log("Video Course Lesson Download URL Response: ${response.data}");
      return _extractDownloadUrl(response.data);
    } catch (e) {
      log("Error calling callDownloadVideoCourseLesson: $e");
      rethrow;
    }
  }

  // For book file downloads - uses new API
  Future<String> callDownloadBookFile(String bookId) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/books/$bookId/download",
    );

    log("Book File Download URL Response: ${response.data}");
    return _extractDownloadUrl(response.data);
  }

  /// Kavoosh book download (requires book access).
  Future<String> callDownloadKavooshBook(String bookId) async {
    final response = await dio.get(
      "${Constants.baseUrl}books/$bookId/download",
    );

    log("Kavoosh Book Download URL Response: ${response.data}");
    return _extractDownloadUrl(response.data);
  }

  // DEPRECATED: This method is kept for backwards compatibility but should not be used
  // Use callDownloadCourseVideo or callDownloadBookFile instead
  @Deprecated('Use callDownloadCourseVideo or callDownloadBookFile instead')
  Future<GetDownloadUrl> callGetDownloadUrl(String key) async {
    final response = await dio.get(
      "${Constants.baseUrl}storage/download/$key",
    );

    // log("Download URL Response: ${response.data}");
    return GetDownloadUrl.fromJson(response.data);
  }

  void _logDecryptKeyDebug(String message) {
    log('[BookDecrypt] $message', name: 'StorageService');
    print('[BookDecrypt] $message');
  }

  void _logDecryptKeyError({
    required String fileId,
    required String url,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      final headers = error.response?.headers.map;
      _logDecryptKeyDebug(
        'Decrypt key request failed\n'
        '  fileId: $fileId\n'
        '  url: $url\n'
        '  statusCode: $status\n'
        '  dioType: ${error.type}\n'
        '  message: ${error.message}\n'
        '  responseData: $data\n'
        '  responseHeaders: $headers',
      );
      return;
    }

    if (error is UnauthorisedException) {
      _logDecryptKeyDebug(
        'Decrypt key unauthorized\n'
        '  fileId: $fileId\n'
        '  url: $url\n'
        '  message: ${error.message}',
      );
      return;
    }

    _logDecryptKeyDebug(
      'Decrypt key unexpected error\n'
      '  fileId: $fileId\n'
      '  url: $url\n'
      '  error: $error\n'
      '  stackTrace: $stackTrace',
    );
  }

  Future<GetDeceryptKey> callGetDecryptedFile(String fileId) async {
    final url = '${Constants.baseUrl}storage/key/$fileId';
    final authService = locator<AuthService>();
    final token = await locator<PrefsOperator>().getUserToken();
    final tokenPreview = token == null
        ? 'null'
        : '${token.substring(0, 20)}...${token.substring(token.length - 8)}';

    _logDecryptKeyDebug(
      'Requesting decrypt key\n'
      '  fileId: $fileId\n'
      '  url: $url\n'
      '  token: $tokenPreview',
    );

    try {
      final response = await authService.get(url);

      final responseData = response.data;
      final responseMap =
          responseData is Map ? Map<String, dynamic>.from(responseData) : null;
      final dataMap = responseMap?['data'];
      final nestedData =
          dataMap is Map ? Map<String, dynamic>.from(dataMap) : null;

      _logDecryptKeyDebug(
        'Decrypt key response\n'
        '  fileId: $fileId\n'
        '  statusCode: ${response.statusCode}\n'
        '  ok: ${responseMap?['ok']}\n'
        '  responseFileId: ${nestedData?['fileId']}\n'
        '  hasKey: ${nestedData?['key'] != null}',
      );

      return GetDeceryptKey.fromJson(response.data);
    } catch (error, stackTrace) {
      _logDecryptKeyError(
        fileId: fileId,
        url: url,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> canDecryptFile(String fileId) async {
    _logDecryptKeyDebug('Checking decrypt permission for fileId: $fileId');
    try {
      await callGetDecryptedFile(fileId);
      _logDecryptKeyDebug('Decrypt permission granted for fileId: $fileId');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        _logDecryptKeyDebug(
          'Decrypt permission denied for fileId: $fileId '
          '(status=${e.response?.statusCode})',
        );
        return false;
      }
      rethrow;
    } on UnauthorisedException {
      _logDecryptKeyDebug(
        'Decrypt permission denied for fileId: $fileId (not logged in)',
      );
      return false;
    }
  }

  String getDownloadPublicUrl(String key) {
    return "${Constants.baseUrl}storage/public/$key";
  }

  Future<String> callGetDownloadPublicUrl(String key) async {
    final publicUrl = getDownloadPublicUrl(key);
    // log("Public Download URL: $publicUrl");
    return publicUrl;
  }
}
