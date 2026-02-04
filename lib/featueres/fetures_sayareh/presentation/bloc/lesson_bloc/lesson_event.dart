part of 'lesson_bloc.dart';

sealed class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object> get props => [];
}

class GetLessonEvenet extends LessonEvent {
  final String id;
  GetLessonEvenet({required this.id});
}

class ResetLessonProgressEvent extends LessonEvent {
  final String id;
  ResetLessonProgressEvent({required this.id});
}
