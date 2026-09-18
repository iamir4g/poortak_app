part of 'quiz_progress_bloc.dart';

abstract class QuizProgressEvent extends Equatable {
  const QuizProgressEvent();

  @override
  List<Object> get props => [];
}

class FetchQuizProgressEvent extends QuizProgressEvent {
  final String courseId;
  final String quizId;

  const FetchQuizProgressEvent({
    required this.courseId,
    required this.quizId,
  });

  @override
  List<Object> get props => [courseId, quizId];
}

/// Updates progress locally from submit-answer response stats (no extra fetch).
class UpdateQuizProgressFromStatsEvent extends QuizProgressEvent {
  final String quizId;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;

  const UpdateQuizProgressFromStatsEvent({
    required this.quizId,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
  });

  @override
  List<Object> get props =>
      [quizId, totalQuestions, answeredQuestions, correctAnswers];
}
