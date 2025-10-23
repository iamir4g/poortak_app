part of 'practice_vocabulary_bloc.dart';

// Model for storing reviewed vocabulary with answer status
class ReviewedVocabulary extends Equatable {
  final Word word;
  final bool isCorrect;

  const ReviewedVocabulary({
    required this.word,
    required this.isCorrect,
  });

  @override
  List<Object> get props => [word, isCorrect];
}

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
  final List<ReviewedVocabulary> reviewedVocabularies;
  final int correctAnswersCount;
  final int wrongAnswersCount;

  const PracticeVocabularySuccess({
    required this.practiceVocabulary,
    this.correctWords = const [],
    this.reviewedVocabularies = const [],
    this.correctAnswersCount = 0,
    this.wrongAnswersCount = 0,
  });

  @override
  List<Object> get props => [
        practiceVocabulary,
        correctWords,
        reviewedVocabularies,
        correctAnswersCount,
        wrongAnswersCount,
      ];
}

class PracticeVocabularyError extends PracticeVocabularyState {
  final String message;

  const PracticeVocabularyError({required this.message});

  @override
  List<Object> get props => [message];
}

class PracticeVocabularyCompleted extends PracticeVocabularyState {
  final List<ReviewedVocabulary> reviewedVocabularies;
  final int correctAnswersCount;
  final int wrongAnswersCount;
  final int totalQuestions;

  const PracticeVocabularyCompleted({
    required this.reviewedVocabularies,
    required this.correctAnswersCount,
    required this.wrongAnswersCount,
    required this.totalQuestions,
  });

  @override
  List<Object> get props => [
        reviewedVocabularies,
        correctAnswersCount,
        wrongAnswersCount,
        totalQuestions,
      ];
}
