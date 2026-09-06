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
