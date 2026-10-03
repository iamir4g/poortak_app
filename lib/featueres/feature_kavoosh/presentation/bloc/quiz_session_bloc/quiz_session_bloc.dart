import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/quiz_models.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';

part 'quiz_session_event.dart';
part 'quiz_session_state.dart';

class QuizSessionBloc extends Bloc<QuizSessionEvent, QuizSessionState> {
  final KavooshRepository repository;

  QuizSessionBloc({required this.repository}) : super(QuizSessionInitial()) {
    on<StartQuizSessionEvent>(_onStart);
    on<SubmitQuizAnswerEvent>(_onSubmitAnswer);
    on<LoadNextQuestionEvent>(_onLoadNext);
    on<FinishQuizSessionEvent>(_onFinish);
    on<ResetQuizSessionEvent>(_onReset);
  }

  Future<void> _onStart(
    StartQuizSessionEvent event,
    Emitter<QuizSessionState> emit,
  ) async {
    emit(QuizSessionLoading());

    final result = await repository.startQuiz(
      quizId: event.quizId,
      questionCount: event.questionCount,
    );

    if (result is DataSuccess && result.data != null) {
      final session = result.data!;
      if (session.question == null) {
        final finishResult =
            await repository.finishAttempt(attemptId: session.attempt.id);
        if (finishResult is DataSuccess && finishResult.data != null) {
          emit(QuizSessionFinished(finishResult.data!));
        } else if (finishResult is DataFailed) {
          emit(QuizSessionError(
            finishResult.error ?? 'خطا در اتمام آزمون',
          ));
        }
        return;
      }
      emit(QuizSessionLoaded(session));
    } else if (result is DataFailed) {
      emit(QuizSessionError(result.error ?? 'خطا در شروع آزمون'));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitQuizAnswerEvent event,
    Emitter<QuizSessionState> emit,
  ) async {
    final current = state;
    final question = current is QuizSessionLoaded
        ? current.session.question
        : current is QuizAnswerFeedback
            ? current.question
            : null;
    final attemptId = current is QuizSessionLoaded
        ? current.session.attempt.id
        : current is QuizAnswerFeedback
            ? current.attemptId
            : event.attemptId;

    if (question == null) {
      emit(const QuizSessionError('سوال فعلی یافت نشد'));
      return;
    }

    emit(QuizSessionSubmitting(
      attemptId: attemptId,
      question: question,
      stats: current is QuizSessionLoaded
          ? current.session.stats
          : current is QuizAnswerFeedback
              ? current.stats
              : const QuizStats(total: 0, answered: 0),
      selectedAnswerId: event.answerId,
    ));

    final result = await repository.submitQuizAnswer(
      attemptId: attemptId,
      questionId: event.questionId,
      answerId: event.answerId,
    );

    if (result is DataSuccess && result.data != null) {
      emit(QuizAnswerFeedback(
        attemptId: attemptId,
        question: question,
        answerResult: result.data!,
        selectedAnswerId: event.answerId,
        stats: result.data!.stats,
      ));
    } else if (result is DataFailed) {
      emit(QuizSessionError(result.error ?? 'خطا در ثبت پاسخ'));
    }
  }

  Future<void> _onLoadNext(
    LoadNextQuestionEvent event,
    Emitter<QuizSessionState> emit,
  ) async {
    final current = state;
    final attemptId = current is QuizAnswerFeedback
        ? current.attemptId
        : event.attemptId;
    final stats =
        current is QuizAnswerFeedback ? current.stats : null;

    if (stats != null &&
        stats.total > 0 &&
        stats.answered >= stats.total) {
      await _finishAndEmit(attemptId, emit);
      return;
    }

    emit(QuizSessionLoading());

    final result = await repository.fetchAttemptState(attemptId: attemptId);

    if (result is DataSuccess && result.data != null) {
      final session = result.data!;
      if (session.question == null) {
        await _finishAndEmit(attemptId, emit);
        return;
      }
      emit(QuizSessionLoaded(session));
    } else if (result is DataFailed) {
      emit(QuizSessionError(result.error ?? 'خطا در دریافت سوال بعدی'));
    }
  }

  Future<void> _finishAndEmit(
    String attemptId,
    Emitter<QuizSessionState> emit,
  ) async {
    emit(QuizSessionLoading());
    final result = await repository.finishAttempt(attemptId: attemptId);
    if (result is DataSuccess && result.data != null) {
      emit(QuizSessionFinished(result.data!));
    } else if (result is DataFailed) {
      emit(QuizSessionError(result.error ?? 'خطا در اتمام آزمون'));
    }
  }

  Future<void> _onFinish(
    FinishQuizSessionEvent event,
    Emitter<QuizSessionState> emit,
  ) async {
    emit(QuizSessionLoading());

    final result = await repository.finishAttempt(attemptId: event.attemptId);

    if (result is DataSuccess && result.data != null) {
      emit(QuizSessionFinished(result.data!));
    } else if (result is DataFailed) {
      emit(QuizSessionError(result.error ?? 'خطا در اتمام آزمون'));
    }
  }

  void _onReset(
    ResetQuizSessionEvent event,
    Emitter<QuizSessionState> emit,
  ) {
    emit(QuizSessionInitial());
  }
}
