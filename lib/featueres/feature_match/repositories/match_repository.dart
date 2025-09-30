import 'package:poortak/featueres/feature_match/data/data_source/match_api_provider.dart';
import 'package:poortak/featueres/feature_match/data/models/submit_answer_model.dart';
import 'package:poortak/featueres/feature_match/data/models/match_model.dart';

class MatchRepository {
  final MatchApiProvider _apiProvider;

  MatchRepository(this._apiProvider);

  // Future methods for match-related operations will be added here
  // For example:
  // Future<MatchModel> getMatchDetails() async { ... }
  // Future<List<WinnerModel>> getWinners() async { ... }
  // Future<List<PrizeModel>> getPrizes() async { ... }

  Future<Match> getMatch() async {
    final response = await _apiProvider.callGetMatch();
    return Match.fromJson(response.data);
  }

  Future<ResponseSubmitAnswer> postSubmitAnswer(
      String matchId, String answer) async {
    final response = await _apiProvider.submitAnswer(matchId, answer);
    return ResponseSubmitAnswer.fromJson(response.data);
  }

  // Future<List<WinnerModel>> getWinners() async {
  //   final response = await _apiProvider.callGetWinners();
  //   return response.data.map((e) => WinnerModel.fromJson(e)).toList();
  // }
}
