import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/models/decerypt_key_response.dart';
import 'package:poortak/config/constants.dart';
// import '../models/storage_file.dart';
import '../models/download_url_response.dart';

class StorageService {
  final Dio dio;

  StorageService({required this.dio});

  // For course video downloads - uses new API
  Future<String> callDownloadCourseVideo(String courseId) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}iknow/courses/$courseId/download",
      );

      log("Course Video Download URL Response: ${response.data}");

      // Response structure: {ok: true, meta: {}, data: "url"}
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;

        // Check if the response has a data field which contains the URL
        if (data.containsKey('data') && data['data'] is String) {
          final url = data['data'] as String;
          log("Extracted URL: $url");
          return url;
        }

        // Check if the response has a url field (fallback)
        if (data.containsKey('url')) {
          return data['url'] as String;
        }
      }

      // Otherwise return the data as string
      return response.data.toString();
    } catch (e) {
      log("Error calling callDownloadCourseVideo: $e");
      rethrow;
    }
  }

  // For book file downloads - uses new API
  Future<String> callDownloadBookFile(String bookId) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/books/$bookId/download",
    );

    log("Book File Download URL Response: ${response.data}");

    // Response structure: {ok: true, meta: {}, data: "url"}
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;

      // Check if the response has a data field which contains the URL
      if (data.containsKey('data') && data['data'] is String) {
        final url = data['data'] as String;
        log("Extracted URL: $url");
        return url;
      }

      // Check if the response has a url field (fallback)
      if (data.containsKey('url')) {
        return data['url'] as String;
      }
    }

    // Otherwise return the data as string
    return response.data.toString();
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
  // 'https://api.poortak.ir/api/v1/storage/key/{fileId}'

  Future<GetDeceryptKey> callGetDecryptedFile(String fileId) async {
    final response = await dio.get(
      "${Constants.baseUrl}storage/key/$fileId",
    );

    log("Sayareh Storage File URL: ${response.data}");
    return GetDeceryptKey.fromJson(response.data);
  }

  Future<String> callGetDownloadPublicUrl(String key) async {
    // For public downloads, the API returns the image binary data directly
    // We need to construct the URL manually since the response is binary
    final publicUrl = "${Constants.baseUrl}storage/public/$key";
    // log("Public Download URL: $publicUrl");
    return publicUrl;
  }
}
