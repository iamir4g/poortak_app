part of 'lesson_bloc.dart';

sealed class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object> get props => [];
}

final class LessonInitial extends LessonState {}

final class LessonLoading extends LessonState {}

final class LessonSuccess extends LessonState {
  final Lesson lesson;
  LessonSuccess({required this.lesson});
}

final class LessonError extends LessonState {
  final String message;
  LessonError({required this.message});
}
