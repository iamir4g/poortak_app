part of 'converstion_bloc.dart';

sealed class ConverstionEvent extends Equatable {
  const ConverstionEvent();

  @override
  List<Object> get props => [];
}

class GetConversationEvent extends ConverstionEvent {
  final String id;
  const GetConversationEvent({required this.id});
}

class SaveConversationPlaybackEvent extends ConverstionEvent {
  final String courseId;
  final String conversationId;
  const SaveConversationPlaybackEvent({
    required this.courseId,
    required this.conversationId,
  });

  @override
  List<Object> get props => [courseId, conversationId];
}
