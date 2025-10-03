import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/locator.dart';

class MatchApiProvider {
  final AuthService _authService;

  MatchApiProvider(Dio dio) : _authService = locator<AuthService>();

  // API methods for match-related operations will be added here
  // For example:
  // Future<Response> getMatchDetails() async { ... }
  // Future<Response> getWinners() async { ... }
  // Future<Response> getPrizes() async { ... }

  dynamic callGetMatch() async {
    final response = await _authService.get(
      "${Constants.baseUrl}matches",
    );

    log("Match Response: ${response.data}");
    return response;
  }

  dynamic callGetLeaderboard(String matchId) async {
    final response = await _authService.get(
      "${Constants.baseUrl}matches/leaderboards",
    );

    log("Leaderboard Response: ${response.data}");
    return response;
  }

  dynamic submitAnswer(String matchId, String answer) async {
    final response = await _authService.post(
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
