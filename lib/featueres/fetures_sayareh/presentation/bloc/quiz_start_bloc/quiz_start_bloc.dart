import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quiez_question_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'quiz_start_event.dart';
part 'quiz_start_state.dart';

class QuizStartBloc extends Bloc<QuizStartEvent, QuizStartState> {
  final SayarehRepository _sayarehRepository;

  QuizStartBloc(this._sayarehRepository) : super(QuizStartInitial()) {
    on<StartQuizEvent>(_onStartQuiz);
  }

  Future<void> _onStartQuiz(
    StartQuizEvent event,
    Emitter<QuizStartState> emit,
  ) async {
    emit(QuizStartLoading());

    final result = await _sayarehRepository.fetchStartQuizQuestion(
      event.courseId,
      event.quizId,
    );

    if (result is DataSuccess && result.data != null) {
      emit(QuizStartLoaded(result.data!));
    } else if (result is DataFailed) {
      emit(QuizStartError(result.error ?? 'An error occurred'));
    }
  }
}
