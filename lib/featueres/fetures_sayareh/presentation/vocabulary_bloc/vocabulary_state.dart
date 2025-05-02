part of 'vocabulary_bloc.dart';

sealed class VocabularyState extends Equatable {
  const VocabularyState();

  @override
  List<Object> get props => [];
}

final class VocabularyInitial extends VocabularyState {}

final class VocabularyLoading extends VocabularyState {}

final class VocabularySuccess extends VocabularyState {
  final VocabularyModel vocabulary;
  const VocabularySuccess({required this.vocabulary});
}

final class VocabularyError extends VocabularyState {
  final String message;
  const VocabularyError({required this.message});
}
