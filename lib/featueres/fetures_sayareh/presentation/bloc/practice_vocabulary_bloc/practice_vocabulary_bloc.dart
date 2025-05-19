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
      final response = await sayarehRepository.fetchPracticeVocabulary(
        event.courseId,
        event.previousVocabularyIds,
      );
      if (response is DataSuccess) {
        if (response.data != null) {
          emit(PracticeVocabularySuccess(
            practiceVocabulary: response.data!,
            correctWords: event.previousVocabularyIds ?? [],
          ));
        } else {
          emit(PracticeVocabularyCompleted());
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
        ));
      }
    });
  }
}
