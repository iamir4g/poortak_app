import 'dart:developer';
import 'package:dio/dio.dart';
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

    log("Download URL Response: ${response.data}");
    return GetDownloadUrl.fromJson(response.data);
  }

  /// Fetches the download URL for a file using its key
//   Future<String> getDownloadUrl(String key) async {
//     try {
//       final response =
//           await dio.get<Map<String, dynamic>>('storage/download/$key');

//       if (response.data != null) {
//         final downloadResponse = DownloadUrlResponse.fromJson(response.data!);
//         return downloadResponse.downloadUrl;
//       }

//       throw Exception('Failed to get download URL: Empty response');
//     } catch (e) {
//       throw Exception('Failed to get download URL: ${e.toString()}');
//     }
//   }

//   /// Helper method to get download URLs for multiple files
//   Future<List<String>> getDownloadUrls(List<StorageFile> files) async {
//     final urls =
//         await Future.wait(files.map((file) => getDownloadUrl(file.key)));
//     return urls;
//   }
}
