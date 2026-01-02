import 'package:dio/dio.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/dictionary_model.dart';

class DictionaryRepository {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://freedictionaryapi.com/api/v1';

  Future<DictionaryEntry?> searchWord(String word) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/entries/en/$word',
        queryParameters: {'translations': true},
      );

      if (response.statusCode == 200) {
        // The API returns an object (EntriesByLanguageAndWord)
        return DictionaryEntry.fromJson(response.data);
      }
      return null;
    } catch (e) {
      // If 404, it means word not found
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw e;
    }
  }
}
