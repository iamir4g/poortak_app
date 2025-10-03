import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/error_handling/check_exception.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_match/data/data_source/match_api_provider.dart';
import 'package:poortak/featueres/feature_match/data/models/submit_answer_model.dart';
import 'package:poortak/featueres/feature_match/data/models/match_model.dart';

class MatchRepository {
  final MatchApiProvider _apiProvider;

  MatchRepository(this._apiProvider);

  Future<DataState<Match>> getMatch() async {
    try {
      final response = await _apiProvider.callGetMatch();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Match.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(
            response.data['message'] ?? "خطا در دریافت اطلاعات مسابقه");
      }
    } on AppException catch (e) {
      return CheckExceptions.getError<Match>(e);
    }
  }

  Future<DataState<ResponseSubmitAnswer>> postSubmitAnswer(
      String matchId, String answer) async {
    try {
      final response = await _apiProvider.submitAnswer(matchId, answer);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ResponseSubmitAnswer.fromJson(response.data);
        return DataSuccess(data);
      } else {
        return DataFailed(response.data['message'] ?? "خطا در ارسال پاسخ");
      }
    } on AppException catch (e) {
      return CheckExceptions.getError<ResponseSubmitAnswer>(e);
    }
  }

  // Future<DataState<List<WinnerModel>>> getWinners() async {
  //   try {
  //     final response = await _apiProvider.callGetWinners();
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final data = response.data.map((e) => WinnerModel.fromJson(e)).toList();
  //       return DataSuccess(data);
  //     } else {
  //       return DataFailed(response.data['message'] ?? "خطا در دریافت لیست برندگان");
  //     }
  //   } on AppException catch (e) {
  //     return CheckExceptions.getError<List<WinnerModel>>(e);
  //   }
  // }
}
