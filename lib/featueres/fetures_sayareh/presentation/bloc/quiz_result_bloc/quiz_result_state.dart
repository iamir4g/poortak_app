part of 'quiz_result_bloc.dart';

abstract class QuizResultState extends Equatable {
  const QuizResultState();

  @override
  List<Object?> get props => [];
}

class QuizResultInitial extends QuizResultState {}

class QuizResultLoading extends QuizResultState {}

class QuizResultLoaded extends QuizResultState {
  final int totalQuestions;
  final int correctAnswers;
  final double score;

  const QuizResultLoaded({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  @override
  List<Object?> get props => [totalQuestions, correctAnswers, score];
}

class QuizResultError extends QuizResultState {
  final String message;

  const QuizResultError(this.message);

  @override
  List<Object?> get props => [message];
}
