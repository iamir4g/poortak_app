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
  final String? errorCode;
  const ConverstionError(this.message, {this.errorCode});

  @override
  List<Object> get props => [message, errorCode ?? ''];
}

final class ConverstionSuccess extends ConverstionState {
  final ConversationModel data;
  final String? lastConversationId;
  const ConverstionSuccess(this.data, {this.lastConversationId});

  @override
  List<Object> get props => [data, lastConversationId ?? ""];
}
