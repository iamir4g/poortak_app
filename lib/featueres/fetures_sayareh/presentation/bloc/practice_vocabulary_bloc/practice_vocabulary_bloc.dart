import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/practice_vocabulary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'practice_vocabulary_event.dart';
part 'practice_vocabulary_state.dart';

class PracticeVocabularyBloc
    extends Bloc<PracticeVocabularyEvent, PracticeVocabularyState> {
  final SayarehRepository sayarehRepository;

  PracticeVocabularyBloc({required this.sayarehRepository})
      : super(PracticeVocabularyInitial()) {
    on<PracticeVocabularyFetchEvent>((event, emit) async {
      emit(PracticeVocabularyLoading());

      // Get previous state data if exists
      List<ReviewedVocabulary> previousReviewed = [];
      int previousCorrectCount = 0;
      int previousWrongCount = 0;

      if (state is PracticeVocabularySuccess) {
        final currentState = state as PracticeVocabularySuccess;
        previousReviewed = currentState.reviewedVocabularies;
        previousCorrectCount = currentState.correctAnswersCount;
        previousWrongCount = currentState.wrongAnswersCount;
      }

      final response = await sayarehRepository.fetchPracticeVocabulary(
        event.courseId,
        event.previousVocabularyIds,
      );
      if (response is DataSuccess) {
        if (response.data != null) {
          emit(PracticeVocabularySuccess(
            practiceVocabulary: response.data!,
            correctWords: event.previousVocabularyIds,
            reviewedVocabularies: previousReviewed,
            correctAnswersCount: previousCorrectCount,
            wrongAnswersCount: previousWrongCount,
          ));
        } else {
          // API returned null, practice completed
          final totalQuestions = previousCorrectCount + previousWrongCount;
          emit(PracticeVocabularyCompleted(
            reviewedVocabularies: previousReviewed,
            correctAnswersCount: previousCorrectCount,
            wrongAnswersCount: previousWrongCount,
            totalQuestions: totalQuestions,
          ));
        }
      } else {
        emit(PracticeVocabularyError(
            message: response.error ?? "خطا در دریافت اطلاعات"));
      }
    });

    on<PracticeVocabularySaveCorrectEvent>((event, emit) async {
      if (state is PracticeVocabularySuccess) {
        final currentState = state as PracticeVocabularySuccess;
        final updatedCorrectWords = [
          ...currentState.correctWords,
          event.wordId
        ];
        emit(PracticeVocabularySuccess(
          practiceVocabulary: currentState.practiceVocabulary,
          correctWords: updatedCorrectWords,
          reviewedVocabularies: currentState.reviewedVocabularies,
          correctAnswersCount: currentState.correctAnswersCount,
          wrongAnswersCount: currentState.wrongAnswersCount,
        ));
      }
    });

    on<PracticeVocabularySaveAnswerEvent>((event, emit) async {
      if (state is PracticeVocabularySuccess) {
        final currentState = state as PracticeVocabularySuccess;

        final newReviewedVocabulary = ReviewedVocabulary(
          word: event.word,
          isCorrect: event.isCorrect,
        );

        final updatedReviewed = [
          ...currentState.reviewedVocabularies,
          newReviewedVocabulary,
        ];

        final updatedCorrectCount = event.isCorrect
            ? currentState.correctAnswersCount + 1
            : currentState.correctAnswersCount;

        final updatedWrongCount = !event.isCorrect
            ? currentState.wrongAnswersCount + 1
            : currentState.wrongAnswersCount;

        emit(PracticeVocabularySuccess(
          practiceVocabulary: currentState.practiceVocabulary,
          correctWords: currentState.correctWords,
          reviewedVocabularies: updatedReviewed,
          correctAnswersCount: updatedCorrectCount,
          wrongAnswersCount: updatedWrongCount,
        ));
      }
    });
  }
}
