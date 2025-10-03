import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';

class LitnerApiProvider {
  final Dio dio;
  final AuthService _authService;

  LitnerApiProvider({required this.dio})
      : _authService = locator<AuthService>();

  dynamic callGetLitnerReviewWords() async {
    final response =
        await _authService.get("${Constants.baseUrl}leitner/review");
    log(response.data.toString());
    return response;
  }

  dynamic callPostLitnerCreateWord(String word, String translation) async {
    final response = await _authService.post(
      "${Constants.baseUrl}leitner",
      data: {"word": word, "translation": translation},
    );
    log(response.data.toString());
    return response;
  }

  dynamic callPatchLitnerSubmitReviewWord(String wordId, bool success) async {
    final response = await _authService.patch(
      "${Constants.baseUrl}leitner/$wordId",
      data: {"wordId": wordId, "success": success},
    );
    log(response.data.toString());
    return response;
  }

  dynamic callGetListWords(int size, int page, String order, String boxLevels,
      String? word, String? query) async {
    //curl 'https://poortak-backend.liara.run/api/v1/leitner?size=10&page=1&order=asc&boxLevels=1%2C2%2C3'

    String url =
        "${Constants.baseUrl}leitner?size=$size&page=$page&order=$order&boxLevels=$boxLevels";

    // Add word parameter if it has a value
    if (word != null && word.isNotEmpty) {
      url += "&word=$word";
    }

    // Add query parameter if it has a value
    if (query != null && query.isNotEmpty) {
      url += "&query=$query";
    }

    final response = await _authService.get(url);
    log(response.data.toString());
    return response;
  }

  dynamic callGetOverviewLitner() async {
    //curl https://poortak-backend.liara.run/api/v1/leitner/overview

    final response =
        await _authService.get("${Constants.baseUrl}leitner/overview");
    log(response.data.toString());
    return response;
  }
}
