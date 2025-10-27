import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';

class SayarehApiProvider {
  final Dio dio;
  final AuthService _authService;

  SayarehApiProvider({required this.dio})
      : _authService = locator<AuthService>();

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

  dynamic callGetBookById(String bookId) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/books/$bookId",
    );
    log("Sayareh Single Book Response: ${response.data}");
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
    return await _authService.get(
      "${Constants.baseUrl}iknow/courses/$id/quiz",
    );
  }

  dynamic callGetStartQuizById(String courseId, String quizId) async {
    return await _authService.get(
      "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/start",
    );
  }

  dynamic callPostAnswerQuestion(String courseId, String quizId,
      String questionId, String answerId) async {
    return await _authService.post(
      "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/answer",
      data: {
        "questionId": questionId,
        "answerId": answerId,
      },
    );
  }

  dynamic callGetResultQuestion(String courseId, String quizId) async {
    return await _authService.get(
      "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/result",
    );
  }

  dynamic callSayarehStorageApi() async {
    final response = await dio.get(
      "${Constants.baseUrl}storage",
    );

    log("Sayareh Storage Response: ${response.data}");
    return response; //SayarehStorageTest.fromJson(response.data);
  }

  dynamic callDownloadCourseVideo(String courseId) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses/$courseId/download",
    );

    log("Course Video Download URL: ${response.data}");
    return response;
  }

  dynamic callDownloadBookFile(String bookId) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/books/$bookId/download",
    );

    log("Book File Download URL: ${response.data}");
    return response;
  }

  dynamic callGetConversation(String id) async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/courses/$id/conversation",
    );

    log("Sayareh Conversation Response: ${response.data}");
    return response;
  }

  dynamic callGetIknowAccess() async {
    final response = await dio.get(
      "${Constants.baseUrl}iknow/access",
    );

    log("Iknow Access Response: ${response.data}");
    return response;
  }
}
