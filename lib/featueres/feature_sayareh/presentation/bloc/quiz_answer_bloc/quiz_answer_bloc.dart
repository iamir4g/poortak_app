import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_sayareh/data/models/answer_question_model.dart'
    as answer_model;
import 'package:poortak/featueres/feature_sayareh/data/models/quiz_question_model.dart'
    as question;
import 'package:poortak/featueres/feature_sayareh/repositories/sayareh_repository.dart';

part 'quiz_answer_event.dart';
part 'quiz_answer_state.dart';

enum QuizAnswerFailure {
  alreadyAnswered,
  notFound,
  unauthorized,
  generic,
}

class QuizAnswerBloc extends Bloc<QuizAnswerEvent, QuizAnswerState> {
  final SayarehRepository _sayarehRepository;

  QuizAnswerBloc(this._sayarehRepository) : super(QuizAnswerInitial()) {
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<ResetQuizAnswerEvent>((event, emit) => emit(QuizAnswerInitial()));
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<QuizAnswerState> emit,
  ) async {
    log("=== _onSubmitAnswer START ===");
    log("Submitting answer...");
    emit(QuizAnswerLoading());
    try {
      log("Calling fetchAnswerQuestion...");
      final result = await _sayarehRepository.fetchAnswerQuestion(
        event.courseId,
        event.quizId,
        event.questionId,
        event.answerId,
      );

      log("Answer response received: $result");
      log("Result type: ${result.runtimeType}");

      if (result is DataSuccess) {
        log("Result is DataSuccess");
        if (result.data == null) {
          log("Result data is null, emitting QuizAnswerError");
          emit(const QuizAnswerError(
            "خطا در دریافت داده از سرور. لطفا دوباره تلاش کنید.",
          ));
          return;
        }
        log("Result data exists: ${result.data}");
        log("Checking nextQuestion...");

        question.QuizesQuestion? nextQuestion;
        if (result.data!.data.nextQuestion != null) {
          log("Next question exists in response, creating QuizesQuestion object");
          nextQuestion = question.QuizesQuestion(
            ok: true,
            meta: question.Meta(),
            data: question.Data(
              id: result.data!.data.nextQuestion!.id,
              quizId: result.data!.data.nextQuestion!.quizId,
              title: result.data!.data.nextQuestion!.title,
              explanation: result.data!.data.nextQuestion!.explanation,
              createdAt: result.data!.data.nextQuestion!.createdAt,
              updatedAt: result.data!.data.nextQuestion!.updatedAt,
              answers: (result.data!.data.nextQuestion!.answers ?? [])
                  .map((answer) => question.Answer(
                        id: answer.id,
                        title: answer.title,
                        questionId: answer.questionId,
                      ))
                  .toList(),
            ),
          );
          log("Created nextQuestion object: $nextQuestion");
        } else {
          log("No next question in response data");
        }

        final isLastQuestion = nextQuestion == null;
        log(isLastQuestion
            ? "Last question answered, emitting QuizAnswerLoaded"
            : "Emitting QuizAnswerLoaded with nextQuestion");

        emit(QuizAnswerLoaded(
          isCorrect: result.data!.data.correct,
          explanation: result.data!.data.question.explanation?.toString(),
          nextQuestion: nextQuestion,
          correctAnswerId: result.data!.data.correctAnswer.id,
          selectedAnswerId: event.answerId,
          isLastQuestion: isLastQuestion,
          stats: result.data!.data.stats,
        ));
      } else if (result is DataFailed) {
        log("Result is DataFailed: ${result.error} code=${result.errorCode}");
        emit(QuizAnswerError(
          result.error ?? "خطا در ثبت پاسخ",
          failure: _mapFailure(result.errorCode),
        ));
      }
    } catch (e, stackTrace) {
      log("Error in _onSubmitAnswer: $e");
      log("Stack trace: $stackTrace");
      emit(QuizAnswerError(e.toString()));
    } finally {
      log("=== _onSubmitAnswer END ===");
    }
  }

  QuizAnswerFailure _mapFailure(String? errorCode) {
    switch (errorCode) {
      case 'questionAlreadyAnswered':
        return QuizAnswerFailure.alreadyAnswered;
      case 'questionOrAnswerNotFound':
        return QuizAnswerFailure.notFound;
      case 'unauthorized':
        return QuizAnswerFailure.unauthorized;
      default:
        return QuizAnswerFailure.generic;
    }
  }
}
