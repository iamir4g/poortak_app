import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';

class MatchApiProvider {
  final Dio _dio;
  final PrefsOperator _prefsOperator;

  // SayarehApiProvider({required this.dio})
  //     : _prefsOperator = locator<PrefsOperator>();

  MatchApiProvider(this._dio) : _prefsOperator = locator<PrefsOperator>();

  // API methods for match-related operations will be added here
  // For example:
  // Future<Response> getMatchDetails() async { ... }
  // Future<Response> getWinners() async { ... }
  // Future<Response> getPrizes() async { ... }

  dynamic callGetMatch() async {
    final response = await _dio.get(
      "${Constants.baseUrl}matches",
    );

    log("Match Response: ${response.data}");
    return response;
  }

  dynamic callGetLeaderboard(String matchId) async {
    final response = await _dio.get(
      "${Constants.baseUrl}matches/leaderboards",
    );

    log("Leaderboard Response: ${response.data}");
    return response;
  }

  dynamic submitAnswer(String matchId, String answer) async {
    final response = await _dio.post(
      "${Constants.baseUrl}matches/$matchId",
      data: {
        "answer": answer,
        "matchId": matchId,
      },
    );

    log("Submit Answer Response: ${response.data}");
    return response;
  }
}
