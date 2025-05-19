part of 'quizes_cubit.dart';

sealed class QuizesState extends Equatable {
  const QuizesState();

  @override
  List<Object> get props => [];
}

final class QuizesInitial extends QuizesState {}

final class QuizesLoading extends QuizesState {}

final class QuizesLoaded extends QuizesState {
  final QuizesList quizzes;

  const QuizesLoaded(this.quizzes);

  @override
  List<Object> get props => [quizzes];
}

final class QuizesError extends QuizesState {
  final String message;

  const QuizesError(this.message);

  @override
  List<Object> get props => [message];
}
