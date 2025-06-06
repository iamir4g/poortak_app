import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quiz_question_model.dart'
    as question;
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'quiz_answer_event.dart';
part 'quiz_answer_state.dart';

class QuizAnswerBloc extends Bloc<QuizAnswerEvent, QuizAnswerState> {
  final SayarehRepository _sayarehRepository;

  QuizAnswerBloc(this._sayarehRepository) : super(QuizAnswerInitial()) {
    on<SubmitAnswerEvent>(_onSubmitAnswer);
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
          log("Result data is null, emitting QuizAnswerComplete");
          emit(QuizAnswerComplete());
          return;
        }

        log("Result data exists: ${result.data}");
        log("Checking nextQuestion...");

        // Convert nextQuestion to QuizesQuestion format if it exists
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

        // If there's no next question, emit QuizAnswerComplete
        if (nextQuestion == null) {
          log("nextQuestion is null, emitting QuizAnswerComplete");
          emit(QuizAnswerComplete());
          return;
        }

        log("Emitting QuizAnswerLoaded with nextQuestion");
        emit(QuizAnswerLoaded(
          isCorrect: result.data!.data.correct,
          explanation: result.data!.data.question.explanation?.toString(),
          nextQuestion: nextQuestion,
          correctAnswerId: result.data!.data.correctAnswer.id,
          selectedAnswerId: event.answerId,
        ));
      } else if (result is DataFailed) {
        log("Result is DataFailed: ${result.error}");
        emit(QuizAnswerError(result.error ?? "خطا در ثبت پاسخ"));
      }
    } catch (e, stackTrace) {
      log("Error in _onSubmitAnswer: $e");
      log("Stack trace: $stackTrace");
      emit(QuizAnswerError(e.toString()));
    } finally {
      log("=== _onSubmitAnswer END ===");
    }
  }
}
