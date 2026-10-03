import 'package:dio/dio.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_kavoosh/data/data_source/kavoosh_api_provider.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_book_detail_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/quiz_models.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/video_course_detail_model.dart';

class KavooshRepository {
  final KavooshApiProvider apiProvider;

  KavooshRepository(this.apiProvider);

  Future<DataState<List<CategoryNodeSummary>>> fetchCategoryNodesSummary({
    required KavooshTreeType treeType,
    String? parentCategoryId,
  }) async {
    try {
      final response = await apiProvider.callGetCategoryNodesSummary(
        treeType: treeType,
        parentCategoryId: parentCategoryId,
      );

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت دسته‌بندی‌ها",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final parsed = CategoryNodesSummaryResponse.fromJson(data);
        return DataSuccess(parsed.data);
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت دسته‌بندی‌ها",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت دسته‌بندی‌ها"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<CategoryNodeSummary>> fetchCategoryNodeDetail({
    required String categoryId,
  }) async {
    try {
      final response = await apiProvider.callGetCategoryNodeDetail(
        categoryId: categoryId,
      );

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت جزئیات دسته‌بندی",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final nodeJson = data['data'];
        if (nodeJson is Map<String, dynamic>) {
          return DataSuccess(CategoryNodeSummary.fromJson(nodeJson));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت جزئیات دسته‌بندی",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت جزئیات دسته‌بندی"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  /// Paginated courses/books for a category (incl. sub-tree).
  Future<DataState<Map<String, dynamic>>> fetchCategoryItems({
    required KavooshTreeType treeType,
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String query = '',
  }) async {
    try {
      final Response response;
      if (treeType == KavooshTreeType.video) {
        response = await apiProvider.callGetVideoCoursesByCategory(
          categoryId: categoryId,
          size: size,
          page: page,
          order: order,
          query: query,
        );
      } else {
        response = await apiProvider.callGetBooksByCategory(
          categoryId: categoryId,
          size: size,
          page: page,
          order: order,
          query: query,
        );
      }

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت لیست محتوا",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final items = data['data'];
        final meta = data['meta'];
        return DataSuccess({
          'meta':
              meta is Map ? meta.cast<String, dynamic>() : <String, dynamic>{},
          'data': items is List
              ? items
                  .whereType<Map>()
                  .map((e) => e.cast<String, dynamic>())
                  .toList()
              : <Map<String, dynamic>>[],
        });
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت لیست محتوا",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت لیست محتوا"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<VideoCourseDetailResponse>> fetchVideoCourseDetail({
    required String courseId,
  }) async {
    try {
      final response = await apiProvider.callGetVideoCourseById(
        courseId: courseId,
      );

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت جزئیات دوره",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        return DataSuccess(VideoCourseDetailResponse.fromJson(data));
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت جزئیات دوره",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت جزئیات دوره"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<KavooshBookDetail>> fetchBookDetail({
    required String bookId,
  }) async {
    try {
      final response = await apiProvider.callGetBookById(bookId: bookId);

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت جزئیات کتاب",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        return DataSuccess(KavooshBookDetail.fromJson(data));
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت جزئیات کتاب",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت جزئیات کتاب"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<List<QuizCategory>>> fetchQuizCategories() async {
    try {
      final response = await apiProvider.callGetQuizCategories();

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت دسته‌بندی آزمون‌ها",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final items = data['data'];
        if (items is List) {
          return DataSuccess(
            items
                .whereType<Map>()
                .map((e) => QuizCategory.fromJson(e.cast<String, dynamic>()))
                .toList(),
          );
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت دسته‌بندی آزمون‌ها",
      ));
    } on DioException catch (e) {
      return DataFailed(
          _dioErrorMessage(e, "خطا در دریافت دسته‌بندی آزمون‌ها"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<List<QuizSummary>>> fetchCategoryQuizzes({
    required String categoryId,
    int size = 20,
    int page = 1,
    String order = 'asc',
    String query = '',
  }) async {
    try {
      final response = await apiProvider.callGetCategoryQuizzes(
        categoryId: categoryId,
        size: size,
        page: page,
        order: order,
        query: query.isEmpty ? null : query,
      );

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت لیست آزمون‌ها",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final items = data['data'];
        if (items is List) {
          return DataSuccess(
            items
                .whereType<Map>()
                .map((e) => QuizSummary.fromJson(e.cast<String, dynamic>()))
                .toList(),
          );
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت لیست آزمون‌ها",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت لیست آزمون‌ها"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<QuizAttemptSession>> startQuiz({
    required String quizId,
    required int questionCount,
  }) async {
    try {
      final response = await apiProvider.callStartQuiz(
        quizId: quizId,
        questionCount: questionCount,
      );

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در شروع آزمون",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return DataSuccess(QuizAttemptSession.fromJson(payload));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در شروع آزمون",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در شروع آزمون"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<QuizAttemptSession>> fetchAttemptState({
    required String attemptId,
  }) async {
    try {
      final response =
          await apiProvider.callGetAttemptState(attemptId: attemptId);

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت وضعیت آزمون",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return DataSuccess(QuizAttemptSession.fromJson(payload));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت وضعیت آزمون",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت وضعیت آزمون"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<QuizAnswerResult>> submitQuizAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
  }) async {
    try {
      final response = await apiProvider.callSubmitQuizAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answerId: answerId,
      );

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در ثبت پاسخ",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return DataSuccess(QuizAnswerResult.fromJson(payload));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در ثبت پاسخ",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در ثبت پاسخ"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<QuizAttemptResult>> finishAttempt({
    required String attemptId,
  }) async {
    try {
      final response =
          await apiProvider.callFinishAttempt(attemptId: attemptId);

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در اتمام آزمون",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return DataSuccess(QuizAttemptResult.fromJson(payload));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در اتمام آزمون",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در اتمام آزمون"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<QuizAttemptResult>> fetchQuizResult({
    required String quizId,
  }) async {
    try {
      final response = await apiProvider.callGetQuizResult(quizId: quizId);

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت نتیجه آزمون",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return DataSuccess(QuizAttemptResult.fromJson(payload));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت نتیجه آزمون",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت نتیجه آزمون"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  bool _isHttpFailure(int? statusCode) {
    return statusCode != null && statusCode >= 400;
  }

  String _dioErrorMessage(DioException e, String fallback) {
    final responseData = e.response?.data;
    final parsed = _parseMessage(responseData);
    if (parsed != null) return parsed;
    return e.message ?? fallback;
  }

  String _errorMessage(dynamic data, {required String fallback}) {
    return _parseMessage(data) ?? fallback;
  }

  String? _parseMessage(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'];
    if (message is List) {
      final joined = message.map((e) => e.toString()).where((e) => e.isNotEmpty);
      if (joined.isNotEmpty) return joined.join('\n');
    }
    if (message != null) {
      final text = message.toString();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
