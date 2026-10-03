part of 'quiz_list_bloc.dart';

abstract class QuizListEvent {}

class FetchQuizListEvent extends QuizListEvent {
  final String categoryId;
  final int size;
  final int page;

  FetchQuizListEvent({
    required this.categoryId,
    this.size = 20,
    this.page = 1,
  });
}
