part of 'quiz_start_bloc.dart';

sealed class QuizStartEvent extends Equatable {
  const QuizStartEvent();

  @override
  List<Object> get props => [];
}

class StartQuizEvent extends QuizStartEvent {
  final String courseId;
  final String quizId;

  const StartQuizEvent({
    required this.courseId,
    required this.quizId,
  });

  @override
  List<Object> get props => [courseId, quizId];
}
