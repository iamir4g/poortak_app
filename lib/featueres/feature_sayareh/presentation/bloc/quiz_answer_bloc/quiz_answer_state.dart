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
  final bool isLastQuestion;
  final answer_model.AnswerStats? stats;

  const QuizAnswerLoaded({
    required this.isCorrect,
    this.explanation,
    this.nextQuestion,
    required this.correctAnswerId,
    required this.selectedAnswerId,
    this.isLastQuestion = false,
    this.stats,
  });

  @override
  List<Object?> get props => [
        isCorrect,
        explanation,
        nextQuestion,
        correctAnswerId,
        selectedAnswerId,
        isLastQuestion,
        stats?.all,
        stats?.answered,
        stats?.correct,
      ];
}

class QuizAnswerError extends QuizAnswerState {
  final String message;
  final QuizAnswerFailure failure;

  const QuizAnswerError(
    this.message, {
    this.failure = QuizAnswerFailure.generic,
  });

  @override
  List<Object?> get props => [message, failure];
}
