import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/data_source/sayareh_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/answer_question_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/practice_vocabulary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quiz_question_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quizzes_list_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/result_question_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_storage_test_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/vocabulary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_cubit.dart';

class SayarehRepository {
  SayarehApiProvider sayarehApiProvider;

  SayarehRepository(this.sayarehApiProvider);

  Future<DataState<SayarehHomeModel>> fetchAllCourses() async {
    // Response response = await sayarehApiProvider.callSayarehApi();
    try {
      Response response = await sayarehApiProvider.callGetAllCourses();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = SayarehHomeModel.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
    //return SayarehState(sayarehDataStatus: SayarehDataSuccess(response));
  }

  Future<DataState<Lesson>> fetchCourseById(String id) async {
    try {
      Response response = await sayarehApiProvider.callGetCourseById(id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Lesson.fromJson(response.data['data']);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<ConversationModel>> fetchSayarehConversation(
      String id) async {
    try {
      Response response = await sayarehApiProvider.callGetConversation(id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ConversationModel.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<VocabularyModel>> fetchVocabulary(String id) async {
    try {
      Response response = await sayarehApiProvider.callGetVocabulary(id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = VocabularyModel.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<PracticeVocabularyModel>> fetchPracticeVocabulary(
      String id, List<String>? previousVocabularyIds) async {
    try {
      Response response = await sayarehApiProvider.callPostPracticeVocabulary(
          id, previousVocabularyIds);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] == null) {
          return DataSuccess(null);
        }
        final data = PracticeVocabularyModel.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<QuizesList>> fetchQuizzes(String id) async {
    try {
      Response response = await sayarehApiProvider.callGetQuizzes(id);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = QuizesList.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<QuizesQuestion>> fetchStartQuizQuestion(
      String courseId, String quizId) async {
    try {
      Response response =
          await sayarehApiProvider.callGetStartQuizById(courseId, quizId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = QuizesQuestion.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed<QuizesQuestion>(
            response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return DataFailed<QuizesQuestion>(e.message);
    } catch (e) {
      return DataFailed<QuizesQuestion>(e.toString());
    }
  }

  Future<DataState<AnswerQuestion>> fetchAnswerQuestion(String courseId,
      String quizId, String questionId, String answerId) async {
    log("=== fetchAnswerQuestion START ===");
    log("courseId: $courseId");
    log("quizId: $quizId");
    log("questionId: $questionId");
    log("answerId: $answerId");
    try {
      Response response = await sayarehApiProvider.callPostAnswerQuestion(
          courseId, quizId, questionId, answerId);
      log("Response status code: ${response.statusCode}");
      log("Raw response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // if (response.data == null) {
        //   log("Response data is null, returning DataSuccess(null)");
        //   return DataSuccess(null);
        // }

        // Check if nextQuestion is null in the raw response
        // if (response.data['data'] != null &&
        //     response.data['data']['nextQuestion'] == null) {
        //   log("nextQuestion is null in raw response, returning DataSuccess(null)");
        //   return DataSuccess(null);
        // }

        log("Attempting to parse response data...");
        final data = AnswerQuestion.fromJson(response.data);
        log("Successfully parsed response data");
        log("Returning DataSuccess with parsed data");
        return DataSuccess(data);
      } else {
        log("Error response: ${response.data}");
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      log("AppException caught: $e");
      return await CheckExceptions.getError(e);
    } catch (e) {
      log("Unexpected error: $e");
      return DataFailed(e.toString());
    } finally {
      log("=== fetchAnswerQuestion END ===");
    }
  }

  Future<DataState<ResultQuestion>> fetchResultQuestion(
      String courseId, String quizId) async {
    log("Result Question Course ID: $courseId");
    log("Result Question Quiz ID: $quizId");
    try {
      Response response =
          await sayarehApiProvider.callGetResultQuestion(courseId, quizId);
      log("Result Question Response: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          return DataSuccess(null);
        }
        final data = ResultQuestion.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<SayarehStorageTest>> fetchSayarehStorage() async {
    try {
      Response response = await sayarehApiProvider.callSayarehStorageApi();
      // final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Sayareh Storage Response: ${response.data}");
        final data = SayarehStorageTest.fromJson(response.data);

        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }
}
