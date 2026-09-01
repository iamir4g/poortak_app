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
///
/// [totalQuestions] = API `all`, [currentQuestion] = API `answered` (1-based).
class UpdateQuizProgressFromStatsEvent extends QuizProgressEvent {
  final String quizId;
  final int totalQuestions;
  final int currentQuestion;
  final int correctAnswers;

  const UpdateQuizProgressFromStatsEvent({
    required this.quizId,
    required this.totalQuestions,
    required this.currentQuestion,
    this.correctAnswers = 0,
  });

  @override
  List<Object> get props =>
      [quizId, totalQuestions, currentQuestion, correctAnswers];
}
