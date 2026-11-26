part of 'long_caption_bloc.dart';

sealed class LongCaptionState extends Equatable {
  const LongCaptionState();

  @override
  List<Object?> get props => [];
}

final class LongCaptionInitial extends LongCaptionState {}

final class LongCaptionLoading extends LongCaptionState {}

final class LongCaptionSuccess extends LongCaptionState {
  final LongCaptionModel caption;

  const LongCaptionSuccess({required this.caption});

  @override
  List<Object?> get props => [caption];
}

final class LongCaptionError extends LongCaptionState {
  final String message;

  const LongCaptionError({required this.message});

  @override
  List<Object?> get props => [message];
}
