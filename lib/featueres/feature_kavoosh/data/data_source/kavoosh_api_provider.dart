import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';

class KavooshApiProvider {
  final Dio dio;

  KavooshApiProvider({required this.dio});

  /// GET /categories/nodes/summary?treeType=&parentCategoryId=
  Future<Response> callGetCategoryNodesSummary({
    required KavooshTreeType treeType,
    String? parentCategoryId,
  }) async {
    final queryParameters = <String, dynamic>{'treeType': treeType.apiValue};
    if (parentCategoryId != null && parentCategoryId.isNotEmpty) {
      queryParameters['parentCategoryId'] = parentCategoryId;
    }

    return dio.get(
      "${Constants.baseUrl}categories/nodes/summary",
      queryParameters: queryParameters,
    );
  }

  /// GET /categories/nodes/:categoryId
  Future<Response> callGetCategoryNodeDetail({
    required String categoryId,
  }) {
    return dio.get(
      "${Constants.baseUrl}categories/nodes/$categoryId",
    );
  }

  /// GET /video-courses/category/:categoryId
  Future<Response> callGetVideoCoursesByCategory({
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String? query,
  }) {
    final queryParameters = <String, dynamic>{
      'size': size,
      'page': page,
      'order': order,
    };
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    return dio.get(
      "${Constants.baseUrl}video-courses/category/$categoryId",
      queryParameters: queryParameters,
    );
  }

  /// GET /books/category/:categoryId
  Future<Response> callGetBooksByCategory({
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String? query,
  }) {
    final queryParameters = <String, dynamic>{
      'size': size,
      'page': page,
      'order': order,
    };
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    return dio.get(
      "${Constants.baseUrl}books/category/$categoryId",
      queryParameters: queryParameters,
    );
  }

  /// GET /video-courses/:courseId
  Future<Response> callGetVideoCourseById({
    required String courseId,
  }) {
    return dio.get(
      "${Constants.baseUrl}video-courses/$courseId",
    );
  }

  /// GET /books/:bookId
  Future<Response> callGetBookById({
    required String bookId,
  }) {
    return dio.get(
      "${Constants.baseUrl}books/$bookId",
    );
  }

  /// GET /quiz/categories
  Future<Response> callGetQuizCategories() {
    return dio.get("${Constants.baseUrl}quiz/categories");
  }

  /// GET /quiz/categories/:categoryId/quizzes
  Future<Response> callGetCategoryQuizzes({
    required String categoryId,
    int size = 20,
    int page = 1,
    String order = 'asc',
    String? query,
  }) {
    final queryParameters = <String, dynamic>{
      'size': size,
      'page': page,
      'order': order,
    };
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    return dio.get(
      "${Constants.baseUrl}quiz/categories/$categoryId/quizzes",
      queryParameters: queryParameters,
    );
  }

  /// POST /quiz/:quizId/start
  Future<Response> callStartQuiz({
    required String quizId,
    required int questionCount,
  }) {
    return dio.post(
      "${Constants.baseUrl}quiz/$quizId/start",
      data: {'questionCount': questionCount},
    );
  }

  /// GET /quiz/attempt/:attemptId
  Future<Response> callGetAttemptState({
    required String attemptId,
  }) {
    return dio.get("${Constants.baseUrl}quiz/attempt/$attemptId");
  }

  /// POST /quiz/attempt/:attemptId/answer
  Future<Response> callSubmitQuizAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
  }) {
    return dio.post(
      "${Constants.baseUrl}quiz/attempt/$attemptId/answer",
      data: {
        'questionId': questionId,
        'answerId': answerId,
      },
    );
  }

  /// PATCH /quiz/attempt/:attemptId/finish
  Future<Response> callFinishAttempt({
    required String attemptId,
  }) {
    return dio.patch("${Constants.baseUrl}quiz/attempt/$attemptId/finish");
  }

  /// GET /quiz/:quizId/result
  Future<Response> callGetQuizResult({
    required String quizId,
  }) {
    return dio.get("${Constants.baseUrl}quiz/$quizId/result");
  }
}
