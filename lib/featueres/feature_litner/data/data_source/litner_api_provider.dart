import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';

class LitnerApiProvider {
  final Dio dio;
  final PrefsOperator _prefsOperator;

  LitnerApiProvider({required this.dio})
      : _prefsOperator = locator<PrefsOperator>();

  Future<Response> _makeAuthenticatedRequest(
      Future<Response> Function() request) async {
    final token = await _prefsOperator.getUserToken();
    if (token == null) {
      throw UnauthorisedException(message: 'Please login to continue');
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      log("request: ${request.toString()}");
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        // Clear token and throw unauthorized exception
        await _prefsOperator.logout();
        throw UnauthorisedException(
            message: 'Session expired. Please login again.');
      } else if (e.response?.statusCode == 409) {
        // Return the response for 409 (word already exists) instead of throwing
        return e.response!;
      }
      rethrow;
    }
  }

  dynamic callGetLitnerReviewWords() async {
    final response = await _makeAuthenticatedRequest(
        () => dio.get("${Constants.baseUrl}leitner/review"));
    log(response.data.toString());
    return response;
  }

  dynamic callPostLitnerCreateWord(String word, String translation) async {
    final response = await _makeAuthenticatedRequest(() => dio.post(
          "${Constants.baseUrl}leitner",
          data: {"word": word, "translation": translation},
        ));
    log(response.data.toString());
    return response;
  }

  dynamic callPatchLitnerSubmitReviewWord(String wordId, bool success) async {
    final response = await _makeAuthenticatedRequest(() => dio.patch(
          "${Constants.baseUrl}leitner/$wordId",
          data: {"wordId": wordId, "success": success},
        ));
    log(response.data.toString());
    return response;
  }

  dynamic callGetListWords(int size, int page, String order) async {
    //curl 'https://poortak-backend.liara.run/api/v1/leitner?size=10&page=1&order=asc'

    final response = await _makeAuthenticatedRequest(() => dio.get(
          "${Constants.baseUrl}leitner?size=$size&page=$page&order=$order",
        ));
    log(response.data.toString());
    return response;
  }

  dynamic callGetOverviewLitner() async {
    //curl https://poortak-backend.liara.run/api/v1/leitner/overview

    final response = await _makeAuthenticatedRequest(() => dio.get(
          "${Constants.baseUrl}leitner/overview",
        ));
    log(response.data.toString());
    return response;
  }
}
