part of 'practice_vocabulary_bloc.dart';

abstract class PracticeVocabularyState extends Equatable {
  const PracticeVocabularyState();

  @override
  List<Object> get props => [];
}

class PracticeVocabularyInitial extends PracticeVocabularyState {}

class PracticeVocabularyLoading extends PracticeVocabularyState {}

class PracticeVocabularySuccess extends PracticeVocabularyState {
  final PracticeVocabularyModel practiceVocabulary;
  final List<String> correctWords;

  const PracticeVocabularySuccess({
    required this.practiceVocabulary,
    this.correctWords = const [],
  });

  @override
  List<Object> get props => [practiceVocabulary, correctWords];
}

class PracticeVocabularyError extends PracticeVocabularyState {
  final String message;

  const PracticeVocabularyError({required this.message});

  @override
  List<Object> get props => [message];
}

class PracticeVocabularyCompleted extends PracticeVocabularyState {}
