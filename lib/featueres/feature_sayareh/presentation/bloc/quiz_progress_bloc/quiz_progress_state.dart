part of 'quiz_progress_bloc.dart';

abstract class QuizProgressState extends Equatable {
  const QuizProgressState();

  @override
  List<Object?> get props => [];
}

class QuizProgressInitial extends QuizProgressState {}

class QuizProgressLoading extends QuizProgressState {}

class QuizProgressLoaded extends QuizProgressState {
  final QuizProgressData progress;

  const QuizProgressLoaded(this.progress);

  int get totalQuestions => progress.totalQuestions;

  /// 1-based current question (`answered` from API).
  int get currentQuestion => progress.currentQuestion;

  int get stepIndex => progress.stepIndex;

  @override
  List<Object?> get props => [
        progress.quizId,
        progress.totalQuestions,
        progress.answeredQuestions,
        progress.currentQuestionIndex,
        progress.completed,
        progress.score,
      ];
}

class QuizProgressError extends QuizProgressState {
  final String message;

  const QuizProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
