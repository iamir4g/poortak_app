part of 'quiz_session_bloc.dart';

abstract class QuizSessionState {
  const QuizSessionState();
}

class QuizSessionInitial extends QuizSessionState {}

class QuizSessionLoading extends QuizSessionState {}

class QuizSessionLoaded extends QuizSessionState {
  final QuizAttemptSession session;

  const QuizSessionLoaded(this.session);
}

class QuizSessionSubmitting extends QuizSessionState {
  final String attemptId;
  final QuizQuestion question;
  final QuizStats stats;
  final String selectedAnswerId;

  const QuizSessionSubmitting({
    required this.attemptId,
    required this.question,
    required this.stats,
    required this.selectedAnswerId,
  });
}

class QuizAnswerFeedback extends QuizSessionState {
  final String attemptId;
  final QuizQuestion question;
  final QuizAnswerResult answerResult;
  final String selectedAnswerId;
  final QuizStats stats;

  const QuizAnswerFeedback({
    required this.attemptId,
    required this.question,
    required this.answerResult,
    required this.selectedAnswerId,
    required this.stats,
  });

  bool get isLastQuestion =>
      stats.total > 0 && stats.answered >= stats.total;
}

class QuizSessionFinished extends QuizSessionState {
  final QuizAttemptResult result;

  const QuizSessionFinished(this.result);
}

class QuizSessionError extends QuizSessionState {
  final String message;

  const QuizSessionError(this.message);
}
