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
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final entry = DictionaryEntry.fromJson(response.data);
        if (entry.persianTranslations.isNotEmpty) {
          return entry;
        }
      }
      
      // If no Persian translation found in first API, try fallback
      return await _searchFallback(word);
    } catch (e) {
      print('[DictionaryRepository] Primary API failed, trying fallback: $e');
      return await _searchFallback(word);
    }
  }

  Future<DictionaryEntry?> _searchFallback(String word) async {
    try {
      print('[DictionaryRepository] Fallback search for: $word');
      // Using unofficial Google Translate API as fallback
      final url =
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=fa&dt=t&q=$word';
      
      final response = await _dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List<dynamic>;
        if (data.isNotEmpty && data[0] is List && (data[0] as List).isNotEmpty) {
          final translation = data[0][0][0] as String;
          if (translation.isNotEmpty && translation.toLowerCase() != word.toLowerCase()) {
            return DictionaryEntry(
              word: word,
              persianTranslations: [translation],
              examples: [],
              relatedWords: [],
            );
          }
        }
      }
      return null;
    } catch (e) {
      print('[DictionaryRepository] Fallback failed: $e');
      return null;
    }
  }
}
