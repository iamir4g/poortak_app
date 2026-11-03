part of 'quiz_answer_bloc.dart';

sealed class QuizAnswerEvent extends Equatable {
  const QuizAnswerEvent();

  @override
  List<Object> get props => [];
}

class SubmitAnswerEvent extends QuizAnswerEvent {
  final String courseId;
  final String quizId;
  final String questionId;
  final String answerId;
  final String? questionQuizId;

  const SubmitAnswerEvent({
    required this.courseId,
    required this.quizId,
    required this.questionId,
    required this.answerId,
    this.questionQuizId,
  });

  @override
  List<Object> get props =>
      [courseId, quizId, questionId, answerId, questionQuizId ?? ''];
}

class ResetQuizAnswerEvent extends QuizAnswerEvent {
  const ResetQuizAnswerEvent();
}
