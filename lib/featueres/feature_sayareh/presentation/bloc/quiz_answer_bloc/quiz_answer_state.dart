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
  final String correctAnswerId;
  final String selectedAnswerId;

  const QuizAnswerLoaded({
    required this.isCorrect,
    this.explanation,
    this.nextQuestion,
    required this.correctAnswerId,
    required this.selectedAnswerId,
  });

  @override
  List<Object?> get props =>
      [isCorrect, explanation, nextQuestion, correctAnswerId, selectedAnswerId];
}

class QuizAnswerComplete extends QuizAnswerState {}

class QuizAnswerError extends QuizAnswerState {
  final String message;

  const QuizAnswerError(this.message);

  @override
  List<Object?> get props => [message];
}
