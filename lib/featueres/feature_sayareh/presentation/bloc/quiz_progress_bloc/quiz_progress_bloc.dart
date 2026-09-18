import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/quiz_progress_model.dart';
import 'package:poortak/featueres/feature_sayareh/repositories/sayareh_repository.dart';

part 'quiz_progress_event.dart';
part 'quiz_progress_state.dart';

class QuizProgressBloc extends Bloc<QuizProgressEvent, QuizProgressState> {
  final SayarehRepository repository;

  QuizProgressBloc(
    this.repository, {
    QuizProgressData? initialProgress,
  }) : super(
          initialProgress != null && initialProgress.totalQuestions > 0
              ? QuizProgressLoaded(initialProgress)
              : QuizProgressInitial(),
        ) {
    on<FetchQuizProgressEvent>(_onFetchQuizProgress);
    on<UpdateQuizProgressFromStatsEvent>(_onUpdateFromStats);
  }

  Future<void> _onFetchQuizProgress(
    FetchQuizProgressEvent event,
    Emitter<QuizProgressState> emit,
  ) async {
    if (state is! QuizProgressLoaded) {
      emit(QuizProgressLoading());
    }

    try {
      debugPrint(
        '📡 [QuizProgress] bloc fetch courseId=${event.courseId} quizId=${event.quizId}',
      );
      final result = await repository.fetchQuizProgress(
        event.courseId,
        quizId: event.quizId,
      );

      if (result is DataSuccess) {
        final progress = result.data?.byQuizId(event.quizId);
        if (progress == null || progress.totalQuestions <= 0) {
          debugPrint(
            '📡 [QuizProgress] empty/unusable progress for quizId=${event.quizId} '
            'rawCount=${result.data?.data.length ?? 0}',
          );
          if (state is! QuizProgressLoaded) {
            emit(QuizProgressInitial());
          }
          return;
        }
        debugPrint(
          '📡 [QuizProgress] loaded quizId=${progress.quizId} '
          'total=${progress.totalQuestions} answered=${progress.answeredQuestions} '
          'stepIndex=${progress.stepIndex} completed=${progress.completed}',
        );
        emit(QuizProgressLoaded(progress));
      } else if (result is DataFailed) {
        debugPrint('📡 [QuizProgress] bloc failed: ${result.error}');
        if (state is! QuizProgressLoaded) {
          emit(QuizProgressError(result.error ?? 'خطا در دریافت پیشرفت آزمون'));
        }
      }
    } catch (e) {
      debugPrint('📡 [QuizProgress] bloc error: $e');
      if (state is! QuizProgressLoaded) {
        emit(QuizProgressError(e.toString()));
      }
    }
  }

  void _onUpdateFromStats(
    UpdateQuizProgressFromStatsEvent event,
    Emitter<QuizProgressState> emit,
  ) {
    if (event.totalQuestions <= 0) return;

    final previous =
        state is QuizProgressLoaded ? (state as QuizProgressLoaded).progress : null;

    final lastIndex = event.totalQuestions - 1;
    // API: all = total, answered = 1-based current question number.
    final currentQuestion = event.currentQuestion <= 0
        ? 1
        : event.currentQuestion.clamp(1, event.totalQuestions);
    final zeroBasedIndex = (currentQuestion - 1).clamp(0, lastIndex);

    final progress = QuizProgressData(
      id: previous?.id ?? '',
      quizId: event.quizId.isNotEmpty ? event.quizId : (previous?.quizId ?? ''),
      userId: previous?.userId ?? '',
      totalQuestions: event.totalQuestions,
      answeredQuestions: currentQuestion,
      correctAnswers: event.correctAnswers,
      score: previous?.score ?? 0,
      completed: previous?.completed ?? false,
      currentQuestionIndex: zeroBasedIndex,
    );

    debugPrint(
      '📡 [QuizProgress] updated from answer stats '
      'all=${progress.totalQuestions} answered=${progress.answeredQuestions} '
      'currentQuestion=${progress.currentQuestion} stepIndex=${progress.stepIndex}',
    );
    emit(QuizProgressLoaded(progress));
  }
}
