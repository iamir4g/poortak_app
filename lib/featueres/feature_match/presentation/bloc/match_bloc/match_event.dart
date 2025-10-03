part of 'match_bloc.dart';

sealed class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object> get props => [];
}

class GetMatchEvent extends MatchEvent {
  const GetMatchEvent();
}

class SubmitAnswerEvent extends MatchEvent {
  final String matchId;
  final String answer;

  const SubmitAnswerEvent({
    required this.matchId,
    required this.answer,
  });

  @override
  List<Object> get props => [matchId, answer];
}

