part of 'practice_vocabulary_bloc.dart';

sealed class PracticeVocabularyState extends Equatable {
  const PracticeVocabularyState();

  @override
  List<Object> get props => [];
}

final class PracticeVocabularyInitial extends PracticeVocabularyState {}

final class PracticeVocabularyLoading extends PracticeVocabularyState {}

final class PracticeVocabularySuccess extends PracticeVocabularyState {
  final PracticeVocabularyModel practiceVocabulary;
  final List<String> correctWords;

  const PracticeVocabularySuccess({
    required this.practiceVocabulary,
    this.correctWords = const [],
  });

  @override
  List<Object> get props => [practiceVocabulary, correctWords];
}

final class PracticeVocabularyError extends PracticeVocabularyState {
  final String message;
  const PracticeVocabularyError({required this.message});

  @override
  List<Object> get props => [message];
}
