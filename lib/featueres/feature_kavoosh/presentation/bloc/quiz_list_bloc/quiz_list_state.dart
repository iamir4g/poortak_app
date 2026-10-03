part of 'quiz_list_bloc.dart';

abstract class QuizListState {}

class QuizListInitial extends QuizListState {}

class QuizListLoading extends QuizListState {}

class QuizListLoaded extends QuizListState {
  final List<QuizSummary> quizzes;

  QuizListLoaded(this.quizzes);
}

class QuizListError extends QuizListState {
  final String message;

  QuizListError(this.message);
}
