import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_match/data/models/match_model.dart';
import 'package:poortak/featueres/feature_match/data/models/submit_answer_model.dart';
import 'package:poortak/featueres/feature_match/repositories/match_repository.dart';

part 'match_event.dart';
part 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final MatchRepository matchRepository;

  MatchBloc({required this.matchRepository}) : super(MatchInitial()) {
    on<GetMatchEvent>((event, emit) async {
      emit(MatchLoading());
      final response = await matchRepository.getMatch();
      if (response is DataSuccess) {
        emit(MatchSuccess(match: response.data!));
      } else {
        emit(MatchError(
            message: response.error ?? "خطا در دریافت اطلاعات مسابقه"));
      }
    });

    on<SubmitAnswerEvent>((event, emit) async {
      emit(MatchSubmittingAnswer());
      final response =
          await matchRepository.postSubmitAnswer(event.matchId, event.answer);
      if (response is DataSuccess) {
        emit(MatchAnswerSubmitted(response: response.data!));
      } else {
        emit(MatchError(message: response.error ?? "خطا در ارسال پاسخ"));
      }
    });
  }
}



