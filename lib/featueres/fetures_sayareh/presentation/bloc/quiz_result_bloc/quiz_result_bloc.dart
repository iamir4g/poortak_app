import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'quiz_result_event.dart';
part 'quiz_result_state.dart';

class QuizResultBloc extends Bloc<QuizResultEvent, QuizResultState> {
  final SayarehRepository repository;

  QuizResultBloc(this.repository) : super(QuizResultInitial()) {
    on<FetchQuizResultEvent>(_onFetchQuizResult);
  }

  Future<void> _onFetchQuizResult(
    FetchQuizResultEvent event,
    Emitter<QuizResultState> emit,
  ) async {
    log("FetchQuizResultEvent received");
    emit(QuizResultLoading());
    try {
      log("Calling fetchResultQuestion with courseId: ${event.courseId}, quizId: ${event.quizId}");
      final result = await repository.fetchResultQuestion(
        event.courseId,
        event.quizId,
      );

      if (result is DataSuccess) {
        if (result.data == null) {
          log("Result data is null");
          emit(QuizResultError("نتایج آزمون در دسترس نیست"));
        } else {
          log("Result data received: ${result.data}");
          emit(QuizResultLoaded(
            totalQuestions: result.data!.data.totalQuestions,
            correctAnswers: result.data!.data.correctAnswers,
            score: result.data!.data.score,
          ));
        }
      } else if (result is DataFailed) {
        log("Result failed: ${result.error}");
        emit(QuizResultError(result.error ?? "خطا در دریافت نتایج"));
      }
    } catch (e) {
      log("Error in _onFetchQuizResult: $e");
      emit(QuizResultError(e.toString()));
    }
  }
}
