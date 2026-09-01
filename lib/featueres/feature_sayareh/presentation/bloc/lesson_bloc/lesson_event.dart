part of 'lesson_bloc.dart';

sealed class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object> get props => [];
}

class GetLessonEvenet extends LessonEvent {
  final String id;
  const GetLessonEvenet({required this.id});

  @override
  List<Object> get props => [id];
}

class RefreshLessonProgressEvent extends LessonEvent {
  final String id;
  const RefreshLessonProgressEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class ResetLessonProgressEvent extends LessonEvent {
  final String id;
  const ResetLessonProgressEvent({required this.id});
}
