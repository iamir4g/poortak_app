part of 'quiz_answer_bloc.dart';

abstract class QuizAnswerState extends Equatable {
  const QuizAnswerState();

  @override
  List<Object?> get props => [];
}

class QuizAnswerInitial extends QuizAnswerState {}

class QuizAnswerLoading extends QuizAnswerState {}

class QuizAnswerLoaded extends QuizAnswerState {
  final bool isCorrect;
  final String? explanation;
  final question.QuizesQuestion? nextQuestion;

  const QuizAnswerLoaded({
    required this.isCorrect,
    this.explanation,
    this.nextQuestion,
  });

  @override
  List<Object?> get props => [isCorrect, explanation, nextQuestion];
}

class QuizAnswerComplete extends QuizAnswerState {}

class QuizAnswerError extends QuizAnswerState {
  final String message;

  const QuizAnswerError(this.message);

  @override
  List<Object?> get props => [message];
}
