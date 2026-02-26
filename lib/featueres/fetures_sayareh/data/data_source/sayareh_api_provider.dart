import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';

class SayarehApiProvider {
  final Dio dio;
  final AuthService _authService;

  SayarehApiProvider({required this.dio})
      : _authService = locator<AuthService>();

  dynamic _retryRequest(Future<Response> Function() request) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (true) {
      try {
        return await request();
      } on DioException catch (e) {
        retryCount++;
        bool isTlsError = e.error is HandshakeException &&
            e.error.toString().contains("WRONG_VERSION_NUMBER");
        bool isNetworkError = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError;

        if ((isTlsError || isNetworkError) && retryCount < maxRetries) {
          log("⚠️ API Error (Retry $retryCount/$maxRetries): ${e.message}. Retrying in ${retryDelay.inSeconds}s...");
          await Future.delayed(retryDelay);
          continue;
        }
        rethrow;
      }
    }
  }

  dynamic callGetAllCourses() async {
    return _retryRequest(() => dio.get("${Constants.baseUrl}iknow/courses"));
  }

  dynamic callGetBookList() async {
    return _retryRequest(() => dio.get("${Constants.baseUrl}iknow/books"));
  }

  dynamic callGetBookById(String bookId) async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/books/$bookId"));
  }

  dynamic callGetCourseById(String id) async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/courses/$id"));
  }

  dynamic callGetVocabulary(String id) async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/courses/$id/vocabulary"));
  }

  dynamic callPostPracticeVocabulary(
      String id, List<String>? previousVocabularyIds) async {
    log("previousVocabularyIds: $previousVocabularyIds");
    return _retryRequest(() => dio.post(
          "${Constants.baseUrl}iknow/courses/$id/vocabulary/practice",
          data: {
            "previousVocabularyIds": previousVocabularyIds,
          },
        ));
  }

  dynamic callPostSubmitVocabulary(
    String courseId,
    String vocabularyId,
    String answer,
    List<String> previousVocabularyIds,
  ) async {
    return _retryRequest(() => dio.post(
          "${Constants.baseUrl}iknow/courses/$courseId/vocabulary/$vocabularyId/submit",
          data: {
            "answer": answer,
            "previousVocabularyIds": previousVocabularyIds,
            "vocabularyId": vocabularyId,
          },
        ));
  }

  dynamic callGetQuizzes(String id) async {
    return _retryRequest(() => _authService.get(
          "${Constants.baseUrl}iknow/courses/$id/quiz",
        ));
  }

  dynamic callGetStartQuizById(String courseId, String quizId) async {
    return _retryRequest(() => _authService.get(
          "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/start",
        ));
  }

  dynamic callPostAnswerQuestion(String courseId, String quizId,
      String questionId, String answerId) async {
    return _retryRequest(() => _authService.post(
          "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/answer",
          data: {
            "questionId": questionId,
            "answerId": answerId,
          },
        ));
  }

  dynamic callGetResultQuestion(String courseId, String quizId) async {
    return _retryRequest(() => _authService.get(
          "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/result",
        ));
  }

  dynamic callDeleteQuizResult(String courseId, String quizId) async {
    return _retryRequest(() => _authService.delete(
          "${Constants.baseUrl}iknow/courses/$courseId/quiz/$quizId/result",
        ));
  }

  dynamic callSayarehStorageApi() async {
    return _retryRequest(() => dio.get("${Constants.baseUrl}storage"));
  }

  dynamic callDownloadCourseVideo(String courseId) async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/courses/$courseId/download"));
  }

  dynamic callDownloadBookFile(String bookId) async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/books/$bookId/download"));
  }

  dynamic callGetConversation(String id) async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/courses/$id/conversation"));
  }

  dynamic callGetConversationPlayback(String courseId) async {
    return _retryRequest(() => dio.get(
        "${Constants.baseUrl}iknow/courses/$courseId/conversation/playback"));
  }

  dynamic callPostConversationPlayback(
      String courseId, String conversationId) async {
    log("Sayareh save converstion courseId: $courseId, conversationId: $conversationId");
    return _retryRequest(() => dio.post(
          "${Constants.baseUrl}iknow/courses/$courseId/conversation/playback",
          data: {
            "courseId": courseId,
            "conversationId": conversationId,
          },
        ));
  }

  dynamic callGetCourseProgress(String courseId) async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/courses/$courseId/progress"));
  }

  dynamic callGetAllCoursesProgress() async {
    return _retryRequest(
        () => dio.get("${Constants.baseUrl}iknow/courses/progress"));
  }

  dynamic callDeleteCourseProgress(String courseId) async {
    return _retryRequest(() =>
        dio.delete("${Constants.baseUrl}iknow/courses/$courseId/progress"));
  }

  dynamic callGetIknowAccess() async {
    return _retryRequest(() => dio.get("${Constants.baseUrl}iknow/access"));
  }
}
