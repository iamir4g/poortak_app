import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_litner/data/data_source/litner_api_provider.dart';
import 'package:poortak/featueres/feature_litner/data/models/create_word_model.dart';
import 'package:poortak/featueres/feature_litner/data/models/list_words_model.dart';
import 'package:poortak/featueres/feature_litner/data/models/overview_linter_model.dart';
import 'package:poortak/featueres/feature_litner/data/models/review_words_model.dart';
import 'package:poortak/featueres/feature_litner/data/models/submit_review_word.dart';

class LitnerRepository {
  LitnerApiProvider litnerApiProvider;

  LitnerRepository(this.litnerApiProvider);

  Future<DataState<ReviewWords>> fetchLitnerReviewWords() async {
    try {
      Response response = await litnerApiProvider.callGetLitnerReviewWords();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ReviewWords.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<CreateWord>> fetchLitnerCreateWord(
      String word, String translation) async {
    try {
      Response response =
          await litnerApiProvider.callPostLitnerCreateWord(word, translation);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = CreateWord.fromJson(response.data);
        return DataSuccess(data);
      } else if (response.statusCode == 409) {
        return DataFailed("این لغت قبلا اضافه شده");
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<SubmitReviewWord>> fetchLitnerSubmitReviewWord(
      String wordId, bool success) async {
    try {
      Response response = await litnerApiProvider
          .callPatchLitnerSubmitReviewWord(wordId, success);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = SubmitReviewWord.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<ListWords>> fetchLitnerListWords(
      int size, int page, String order) async {
    try {
      Response response = await litnerApiProvider.callGetListWords(
        size,
        page,
        order,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ListWords.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }

  Future<DataState<OverviewLinter>> fetchLitnerOverview() async {
    try {
      Response response = await litnerApiProvider.callGetOverviewLitner();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = OverviewLinter.fromJson(response.data);
        log(data.toString());
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در دریافت اطلاعات");
      }
    } on AppException catch (e) {
      return await CheckExceptions.getError(e);
    }
  }
}
