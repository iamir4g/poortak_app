part of 'quiz_session_bloc.dart';

abstract class QuizSessionEvent {}

class StartQuizSessionEvent extends QuizSessionEvent {
  final String quizId;
  final int questionCount;

  StartQuizSessionEvent({
    required this.quizId,
    required this.questionCount,
  });
}

class SubmitQuizAnswerEvent extends QuizSessionEvent {
  final String attemptId;
  final String questionId;
  final String answerId;

  SubmitQuizAnswerEvent({
    required this.attemptId,
    required this.questionId,
    required this.answerId,
  });
}

class LoadNextQuestionEvent extends QuizSessionEvent {
  final String attemptId;

  LoadNextQuestionEvent({required this.attemptId});
}

class FinishQuizSessionEvent extends QuizSessionEvent {
  final String attemptId;

  FinishQuizSessionEvent({required this.attemptId});
}

class ResetQuizSessionEvent extends QuizSessionEvent {}
