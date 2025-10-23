import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/vocabulary_model.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

part 'vocabulary_event.dart';
part 'vocabulary_state.dart';

class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  final SayarehRepository sayarehRepository;

  VocabularyBloc({required this.sayarehRepository})
      : super(VocabularyInitial()) {
    on<VocabularyFetchEvent>((event, emit) async {
      emit(VocabularyLoading());
      final response = await sayarehRepository.fetchVocabulary(event.id);
      if (response is DataSuccess && response.data != null) {
        emit(VocabularySuccess(vocabulary: response.data!));
      } else {
        emit(VocabularyError(
            message: response.error ?? "خطا در دریافت اطلاعات"));
      }
    });
  }
}
