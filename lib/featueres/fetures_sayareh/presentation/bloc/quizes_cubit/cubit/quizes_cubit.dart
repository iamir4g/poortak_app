import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/quizzes_list_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';
import 'package:poortak/locator.dart';

part 'quizes_state.dart';

class QuizesCubit extends Cubit<QuizesState> {
  final SayarehRepository _sayarehRepository;

  QuizesCubit()
      : _sayarehRepository = locator<SayarehRepository>(),
        super(QuizesInitial());

  Future<void> fetchQuizzes(String courseId) async {
    emit(QuizesLoading());
    try {
      final result = await _sayarehRepository.fetchQuizzes(courseId);

      // Check if cubit is still open before emitting
      if (isClosed) return;

      if (result is DataSuccess && result.data != null) {
        emit(QuizesLoaded(result.data!));
      } else if (result is DataFailed) {
        emit(QuizesError(result.error ?? 'An error occurred'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(QuizesError(e.toString()));
      }
    }
  }
}
