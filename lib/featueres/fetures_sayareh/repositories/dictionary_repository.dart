import 'package:dio/dio.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/dictionary_model.dart';

class DictionaryRepository {
  final Dio _dio;
  final String _baseUrl = 'https://freedictionaryapi.com/api/v1';

  DictionaryRepository({required Dio dio}) : _dio = dio;

  Future<DictionaryEntry?> searchWord(String word) async {
    try {
      print('[DictionaryRepository] GET $_baseUrl/entries/en/$word');
      final response = await _dio.get(
        '$_baseUrl/entries/en/$word',
        queryParameters: {'translations': true},
        options: Options(
          headers: {'User-Agent': 'PostmanRuntime/7.32.3'},
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      print('[DictionaryRepository] Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print(
            '[DictionaryRepository] Payload type: ${response.data.runtimeType}');
        return DictionaryEntry.fromJson(response.data);
      }
      print('[DictionaryRepository] Non-200 response');
      return null;
    } catch (e) {
      if (e is DioException) {
        print(
            '[DictionaryRepository] DioException: code=${e.response?.statusCode} message=${e.message}');
        print('[DictionaryRepository] Dio data: ${e.response?.data}');
        if (e.response?.statusCode == 404) {
          return null;
        }
      } else {
        print('[DictionaryRepository] Error: $e');
      }
      rethrow;
    }
  }
}
