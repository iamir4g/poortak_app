part of 'quiz_result_bloc.dart';
// import 'package:equatable/equatable.dart';

abstract class QuizResultEvent extends Equatable {
  const QuizResultEvent();

  @override
  List<Object> get props => [];
}

class FetchQuizResultEvent extends QuizResultEvent {
  final String courseId;
  final String quizId;

  const FetchQuizResultEvent({
    required this.courseId,
    required this.quizId,
  });

  @override
  List<Object> get props => [courseId, quizId];
}
