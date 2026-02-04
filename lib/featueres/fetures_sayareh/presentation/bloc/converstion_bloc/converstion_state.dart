part of 'converstion_bloc.dart';

sealed class ConverstionState extends Equatable {
  const ConverstionState();

  @override
  List<Object> get props => [];
}

final class ConverstionInitial extends ConverstionState {}

final class ConverstionLoading extends ConverstionState {}

final class ConverstionError extends ConverstionState {
  final String message;
  ConverstionError(this.message);
}

final class ConverstionSuccess extends ConverstionState {
  final ConversationModel data;
  final String? lastConversationId;
  ConverstionSuccess(this.data, {this.lastConversationId});

  @override
  List<Object> get props => [data, lastConversationId ?? ""];
}
