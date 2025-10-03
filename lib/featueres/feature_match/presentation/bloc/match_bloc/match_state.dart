part of 'match_bloc.dart';

sealed class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object> get props => [];
}

final class MatchInitial extends MatchState {}

final class MatchLoading extends MatchState {}

final class MatchSubmittingAnswer extends MatchState {}

final class MatchSuccess extends MatchState {
  final Match match;
  const MatchSuccess({required this.match});

  @override
  List<Object> get props => [match];
}

final class MatchAnswerSubmitted extends MatchState {
  final ResponseSubmitAnswer response;
  const MatchAnswerSubmitted({required this.response});

  @override
  List<Object> get props => [response];
}

final class MatchError extends MatchState {
  final String message;
  const MatchError({required this.message});

  @override
  List<Object> get props => [message];
}
