import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/practice_vocabulary_model.dart';
import 'package:poortak/featueres/feature_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/locator.dart';

part 'practice_vocabulary_event.dart';
part 'practice_vocabulary_state.dart';

class PracticeVocabularyBloc
    extends Bloc<PracticeVocabularyEvent, PracticeVocabularyState> {
  final SayarehRepository sayarehRepository;

  // Store accumulated data across questions
  List<ReviewedVocabulary> _accumulatedReviewed = [];
  int _accumulatedCorrectCount = 0;
  int _accumulatedWrongCount = 0;
  String? _currentCourseId;
  List<String> _previousVocabularyIds = [];
  final Set<String> _submittedVocabularyIds = {};

  PracticeVocabularyBloc({required this.sayarehRepository})
      : super(PracticeVocabularyInitial()) {
    on<PracticeVocabularyFetchEvent>((event, emit) async {
      _currentCourseId = event.courseId;
      _previousVocabularyIds = _mergeVocabularyIds(
        _storedPreviousVocabularyIds(event.courseId),
        event.previousVocabularyIds,
      );
      _submittedVocabularyIds.addAll(_previousVocabularyIds);
      if (_accumulatedReviewed.isEmpty) {
        _restoreReviewedVocabularies(event.courseId);
      }
      await _persistPreviousVocabularyIds();
      emit(PracticeVocabularyLoading());

      final response = await sayarehRepository.fetchPracticeVocabulary(
        event.courseId,
        _previousVocabularyIds,
      );

      if (response is DataSuccess) {
        if (response.data != null) {
          emit(PracticeVocabularySuccess(
            practiceVocabulary: response.data!,
            correctWords: _previousVocabularyIds,
            reviewedVocabularies: _accumulatedReviewed,
            correctAnswersCount: _accumulatedCorrectCount,
            wrongAnswersCount: _accumulatedWrongCount,
          ));
          await _persistVocabularyProgress(
            response.data!.data.stats.progressPercent,
          );
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
          await _persistReviewedVocabularies(replace: true);
          await _persistVocabularyProgress(100);
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
        _previousVocabularyIds = _mergeVocabularyIds(
          _previousVocabularyIds,
          [event.wordId],
        );
        await _persistPreviousVocabularyIds();
        emit(PracticeVocabularySuccess(
          practiceVocabulary: currentState.practiceVocabulary,
          correctWords: _previousVocabularyIds,
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

        _previousVocabularyIds = _mergeVocabularyIds(
          _previousVocabularyIds,
          [event.word.id],
        );
        await _persistPreviousVocabularyIds();

        print('DEBUG: Answer saved - isCorrect: ${event.isCorrect}');
        print('DEBUG: Word: ${event.word.word}');
        print('DEBUG: Accumulated correct count: $_accumulatedCorrectCount');
        print('DEBUG: Accumulated wrong count: $_accumulatedWrongCount');
        print(
            'DEBUG: Accumulated reviewed count: ${_accumulatedReviewed.length}');

        await _persistReviewedVocabularies();
        emit(PracticeVocabularySuccess(
          practiceVocabulary: currentState.practiceVocabulary,
          correctWords: _previousVocabularyIds,
          reviewedVocabularies: _accumulatedReviewed,
          correctAnswersCount: _accumulatedCorrectCount,
          wrongAnswersCount: _accumulatedWrongCount,
        ));
      }
    });

    on<PracticeVocabularyResetEvent>((event, emit) async {
      _accumulatedReviewed = [];
      _accumulatedCorrectCount = 0;
      _accumulatedWrongCount = 0;
      _submittedVocabularyIds.clear();
      emit(PracticeVocabularyInitial());
    });

    on<PracticeVocabularySubmitEvent>((event, emit) async {
      if (event.vocabularyId.isEmpty ||
          !_submittedVocabularyIds.add(event.vocabularyId)) {
        return;
      }

      final previousForApi = _mergeVocabularyIds(
        _previousVocabularyIds,
        event.previousVocabularyIds,
      ).where((id) => id != event.vocabularyId).toList();

      final response = await sayarehRepository.submitVocabulary(
        event.courseId,
        event.vocabularyId,
        event.answer,
        previousForApi,
      );

      _previousVocabularyIds = _mergeVocabularyIds(
        previousForApi,
        [event.vocabularyId],
      );
      await _persistPreviousVocabularyIds();

      if (response is DataFailed) {
        print('DEBUG: Submit vocabulary failed: ${response.error}');
      }
    });
  }

  Future<void> _persistReviewedVocabularies({bool replace = false}) async {
    final courseId = _currentCourseId;
    if (courseId == null || courseId.isEmpty) return;

    final prefs = locator<PrefsOperator>();
    final latestByWordId = <String, ReviewedVocabulary>{};

    if (!replace) {
      for (final json in prefs.getReviewedVocabulariesJson(courseId)) {
        try {
          final item = ReviewedVocabulary.fromJson(json);
          latestByWordId[item.word.id] = item;
        } catch (_) {}
      }
    }

    for (final item in _accumulatedReviewed) {
      latestByWordId[item.word.id] = item;
    }

    await prefs.saveReviewedVocabulariesJson(
      courseId,
      latestByWordId.values.map((item) => item.toJson()).toList(),
    );
  }

  PrefsOperator get _prefs => locator<PrefsOperator>();

  List<String> _storedPreviousVocabularyIds(String courseId) {
    final stored = _prefs.getPreviousVocabularyIds(courseId);
    if (stored.isNotEmpty) return stored;

    final fromReviewed = <String>[];
    final seen = <String>{};
    for (final json in _prefs.getReviewedVocabulariesJson(courseId)) {
      try {
        final item = ReviewedVocabulary.fromJson(json);
        if (seen.add(item.word.id)) {
          fromReviewed.add(item.word.id);
        }
      } catch (_) {}
    }
    return fromReviewed;
  }

  void _restoreReviewedVocabularies(String courseId) {
    final restored = <ReviewedVocabulary>[];
    for (final json in _prefs.getReviewedVocabulariesJson(courseId)) {
      try {
        restored.add(ReviewedVocabulary.fromJson(json));
      } catch (_) {}
    }
    if (restored.isEmpty) return;

    _accumulatedReviewed = restored;
    _accumulatedCorrectCount =
        restored.where((item) => item.isCorrect == true).length;
    _accumulatedWrongCount =
        restored.where((item) => item.isCorrect == false).length;
  }

  List<String> _mergeVocabularyIds(
    List<String> current,
    List<String> incoming,
  ) {
    final seen = <String>{};
    final merged = <String>[];
    for (final id in [...current, ...incoming]) {
      if (id.isEmpty || !seen.add(id)) continue;
      merged.add(id);
    }
    return merged;
  }

  Future<void> _persistPreviousVocabularyIds() async {
    final courseId = _currentCourseId;
    if (courseId == null || courseId.isEmpty) return;
    await _prefs.savePreviousVocabularyIds(courseId, _previousVocabularyIds);
  }

  Future<void> _persistVocabularyProgress(int percent) async {
    final courseId = _currentCourseId;
    if (courseId == null || courseId.isEmpty) return;
    final current = _prefs.getVocabularyPracticeProgress(courseId);
    if (percent <= current) return;
    await _prefs.saveVocabularyPracticeProgress(courseId, percent);
  }
}
