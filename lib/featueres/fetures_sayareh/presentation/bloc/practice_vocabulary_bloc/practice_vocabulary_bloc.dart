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

  // Store accumulated data across questions
  List<ReviewedVocabulary> _accumulatedReviewed = [];
  int _accumulatedCorrectCount = 0;
  int _accumulatedWrongCount = 0;

  PracticeVocabularyBloc({required this.sayarehRepository})
      : super(PracticeVocabularyInitial()) {
    on<PracticeVocabularyFetchEvent>((event, emit) async {
      emit(PracticeVocabularyLoading());

      final response = await sayarehRepository.fetchPracticeVocabulary(
        event.courseId,
        event.previousVocabularyIds,
      );
      if (response is DataSuccess) {
        if (response.data != null) {
          emit(PracticeVocabularySuccess(
            practiceVocabulary: response.data!,
            correctWords: event.previousVocabularyIds,
            reviewedVocabularies: _accumulatedReviewed,
            correctAnswersCount: _accumulatedCorrectCount,
            wrongAnswersCount: _accumulatedWrongCount,
          ));
        } else {
          // API returned null, practice completed
          final totalQuestions =
              _accumulatedCorrectCount + _accumulatedWrongCount;
          print('DEBUG: Practice completed');
          print('DEBUG: Total questions: $totalQuestions');
          print('DEBUG: Correct answers: $_accumulatedCorrectCount');
          print('DEBUG: Wrong answers: $_accumulatedWrongCount');
          print(
              'DEBUG: Reviewed vocabularies count: ${_accumulatedReviewed.length}');
          emit(PracticeVocabularyCompleted(
            reviewedVocabularies: _accumulatedReviewed,
            correctAnswersCount: _accumulatedCorrectCount,
            wrongAnswersCount: _accumulatedWrongCount,
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
          reviewedVocabularies: _accumulatedReviewed,
          correctAnswersCount: _accumulatedCorrectCount,
          wrongAnswersCount: _accumulatedWrongCount,
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

        // Update accumulated data
        _accumulatedReviewed = [
          ..._accumulatedReviewed,
          newReviewedVocabulary,
        ];

        if (event.isCorrect) {
          _accumulatedCorrectCount++;
        } else {
          _accumulatedWrongCount++;
        }

        print('DEBUG: Answer saved - isCorrect: ${event.isCorrect}');
        print('DEBUG: Word: ${event.word.word}');
        print('DEBUG: Accumulated correct count: $_accumulatedCorrectCount');
        print('DEBUG: Accumulated wrong count: $_accumulatedWrongCount');
        print(
            'DEBUG: Accumulated reviewed count: ${_accumulatedReviewed.length}');

        emit(PracticeVocabularySuccess(
          practiceVocabulary: currentState.practiceVocabulary,
          correctWords: currentState.correctWords,
          reviewedVocabularies: _accumulatedReviewed,
          correctAnswersCount: _accumulatedCorrectCount,
          wrongAnswersCount: _accumulatedWrongCount,
        ));
      }
    });

    on<PracticeVocabularyResetEvent>((event, emit) async {
      // Reset all accumulated data
      _accumulatedReviewed = [];
      _accumulatedCorrectCount = 0;
      _accumulatedWrongCount = 0;

      // Reset to initial state
      emit(PracticeVocabularyInitial());
    });
  }
}
