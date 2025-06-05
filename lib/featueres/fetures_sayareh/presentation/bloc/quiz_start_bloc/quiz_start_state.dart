part of 'quiz_start_bloc.dart';

abstract class QuizStartState extends Equatable {
  const QuizStartState();

  @override
  List<Object> get props => [];
}

class QuizStartInitial extends QuizStartState {}

class QuizStartLoading extends QuizStartState {}

class QuizStartLoaded extends QuizStartState {
  final QuizesQuestion question;

  QuizStartLoaded(this.question);

  @override
  List<Object> get props => [question];
}

class QuizStartError extends QuizStartState {
  final String message;

  QuizStartError(this.message);

  @override
  List<Object> get props => [message];
}
