import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/models/decerypt_key_response.dart';
import 'package:poortak/config/constants.dart';
// import '../models/storage_file.dart';
import '../models/download_url_response.dart';

class StorageService {
  final Dio dio;

  StorageService({required this.dio});

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
