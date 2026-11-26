part of 'long_caption_bloc.dart';

sealed class LongCaptionEvent extends Equatable {
  const LongCaptionEvent();

  @override
  List<Object> get props => [];
}

class GetLongCaptionEvent extends LongCaptionEvent {
  final LongCaptionKey key;

  const GetLongCaptionEvent(this.key);

  @override
  List<Object> get props => [key];
}
