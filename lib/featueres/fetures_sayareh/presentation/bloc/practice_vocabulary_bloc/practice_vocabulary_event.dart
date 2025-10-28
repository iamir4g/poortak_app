part of 'practice_vocabulary_bloc.dart';

sealed class PracticeVocabularyEvent extends Equatable {
  const PracticeVocabularyEvent();

  @override
  List<Object> get props => [];
}

final class PracticeVocabularyFetchEvent extends PracticeVocabularyEvent {
  final String courseId;
  final List<String> previousVocabularyIds;
  const PracticeVocabularyFetchEvent({
    required this.courseId,
    this.previousVocabularyIds = const [],
  });

  @override
  List<Object> get props => [courseId, previousVocabularyIds];
}

final class PracticeVocabularySaveCorrectEvent extends PracticeVocabularyEvent {
  final String wordId;
  const PracticeVocabularySaveCorrectEvent({required this.wordId});

  @override
  List<Object> get props => [wordId];
}

final class PracticeVocabularySaveAnswerEvent extends PracticeVocabularyEvent {
  final Word word;
  final bool isCorrect;
  const PracticeVocabularySaveAnswerEvent({
    required this.word,
    required this.isCorrect,
  });

  @override
  List<Object> get props => [word, isCorrect];
}

final class PracticeVocabularyResetEvent extends PracticeVocabularyEvent {
  const PracticeVocabularyResetEvent();
}
