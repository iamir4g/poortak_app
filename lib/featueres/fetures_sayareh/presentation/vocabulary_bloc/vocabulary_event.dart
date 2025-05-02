part of 'vocabulary_bloc.dart';

sealed class VocabularyEvent extends Equatable {
  const VocabularyEvent();

  @override
  List<Object> get props => [];
}

final class VocabularyFetchEvent extends VocabularyEvent {
  final String id;
  const VocabularyFetchEvent({required this.id});
}
