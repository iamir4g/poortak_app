part of 'converstion_bloc.dart';

sealed class ConverstionEvent extends Equatable {
  const ConverstionEvent();

  @override
  List<Object> get props => [];
}

class GetConversationEvent extends ConverstionEvent {
  final String id;
  GetConversationEvent({required this.id});
}
