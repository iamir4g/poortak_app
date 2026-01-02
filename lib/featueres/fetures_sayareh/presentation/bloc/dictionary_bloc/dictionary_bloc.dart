import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/dictionary_repository.dart';
import 'dictionary_event.dart';
import 'dictionary_state.dart';

class DictionaryBloc extends Bloc<DictionaryEvent, DictionaryState> {
  final DictionaryRepository _repository;

  DictionaryBloc({DictionaryRepository? repository})
      : _repository = repository ?? DictionaryRepository(),
        super(DictionaryInitial()) {
    on<SearchWord>(_onSearchWord);
  }

  Future<void> _onSearchWord(
    SearchWord event,
    Emitter<DictionaryState> emit,
  ) async {
    if (event.word.isEmpty) {
      emit(DictionaryInitial());
      return;
    }

    emit(DictionaryLoading());

    try {
      final entry = await _repository.searchWord(event.word);
      if (entry != null) {
        if (entry.persianTranslations.isEmpty) {
          emit(DictionaryEmpty());
        } else {
          emit(DictionaryLoaded(entry));
        }
      } else {
        emit(DictionaryEmpty());
      }
    } catch (e) {
      emit(DictionaryError("خطا در دریافت اطلاعات"));
    }
  }
}
