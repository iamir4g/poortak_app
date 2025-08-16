import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';
import 'package:poortak/locator.dart';

class SayarehApiProvider {
  final Dio dio;
  final PrefsOperator _prefsOperator;

  SayarehApiProvider({required this.dio})
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

  dynamic callGetAllCourses() async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses",
    );

    log("Sayareh Home Response: ${response.data}");
    return response;
  }

  dynamic callGetBookList() async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/books",
    );
    log("Sayareh Book List Response: ${response.data}");
    return response;
  }

  dynamic callGetCourseById(String id) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses/$id",
    );

    log("Sayareh Course Response: ${response.data}");
    return response;
  }

  dynamic callGetVocabulary(String id) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses/$id/vocabulary",
    );

    log("Sayareh Vocabulary Response: ${response.data}");
    return response;
  }

  dynamic callPostPracticeVocabulary(
      String id, List<String>? previousVocabularyIds) async {
    log("previousVocabularyIds: $previousVocabularyIds");
    final response = await dio.post(
      "${Constants.baseUrl}iknow/courses/$id/vocabulary/practice",
      data: {
        "previousVocabularyIds": previousVocabularyIds,
      },
    );

    log("Sayareh Practice Vocabulary Response: ${response.data}");
    return response;
  }

  dynamic callGetQuizzes(String id) async {
    return await _makeAuthenticatedRequest(() => dio.get(
          "${Constants.baseUrl}iknow/courses/$id/quiz",
        ));
  }

  dynamic callGetStartQuizById(String courseId, String quizId) async {
    return await _makeAuthenticatedRequest(() => dio.get(
          "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/start",
        ));
  }

  dynamic callPostAnswerQuestion(String courseId, String quizId,
      String questionId, String answerId) async {
    return await _makeAuthenticatedRequest(() => dio.post(
          "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/answer",
          data: {
            "questionId": questionId,
            "answerId": answerId,
          },
        ));
  }

  dynamic callGetResultQuestion(String courseId, String quizId) async {
    return await _makeAuthenticatedRequest(() => dio.get(
          "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/result",
        ));
  }

  dynamic callSayarehStorageApi() async {
    final response = await dio.get(
      "${Constants.baseUrl}storage",
    );

    log("Sayareh Storage Response: ${response.data}");
    return response; //SayarehStorageTest.fromJson(response.data);
  }

  dynamic callGetDownloadUrl(String key) async {
    final response = await dio.get(
      "${Constants.baseUrl}storage/download/$key",
    );

    log("Sayareh Storage Download URL: ${response.data}");
    return response; //SayarehStorageTest.fromJson(response.data);
  }

  dynamic callGetConversation(String id) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses/$id/conversation",
    );

    log("Sayareh Conversation Response: ${response.data}");
    return response;
  }
}
