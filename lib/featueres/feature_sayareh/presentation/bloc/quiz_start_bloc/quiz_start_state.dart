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

  const QuizStartLoaded(this.question);

  @override
  List<Object> get props => [question];
}

class QuizStartError extends QuizStartState {
  final String message;

  const QuizStartError(this.message);

  @override
  List<Object> get props => [message];
}
