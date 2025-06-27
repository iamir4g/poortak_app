import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';

class LitnerApiProvider {
  final Dio dio;
  final PrefsOperator _prefsOperator;

  LitnerApiProvider({required this.dio})
      : _prefsOperator = locator<PrefsOperator>();

  dynamic callGetLitnerReviewWords() async {
    final response = await dio.get("${Constants.baseUrl}leitner/review");
    log(response.data.toString());
    return response;
  }

  dynamic callPostLitnerCreateWord(String word, String translation) async {
    final response = await dio.post("${Constants.baseUrl}leitner/create",
        data: {"word": word, "translation": translation});
    log(response.data.toString());
    return response;
  }

  dynamic callPatchLitnerSubmitReviewWord(String wordId, bool success) async {
    final response = await dio.patch(
      "${Constants.baseUrl}leitner/review/$wordId",
      data: {"wordId": wordId, "success": success},
    );
    log(response.data.toString());
    return response;
  }
}
