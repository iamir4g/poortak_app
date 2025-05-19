import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/data_source/sayareh_api_provider.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/conversation_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/practice_vocabulary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quizes_list_model.dart';
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
