part of 'quiz_categories_bloc.dart';

abstract class QuizCategoriesState {}

class QuizCategoriesInitial extends QuizCategoriesState {}

class QuizCategoriesLoading extends QuizCategoriesState {}

class QuizCategoriesLoaded extends QuizCategoriesState {
  final List<QuizCategory> categories;

  QuizCategoriesLoaded(this.categories);
}

class QuizCategoriesError extends QuizCategoriesState {
  final String message;

  QuizCategoriesError(this.message);
}
