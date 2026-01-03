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
      print('[DictionaryBloc] Searching word: ${event.word}');
      final entry = await _repository.searchWord(event.word);
      if (entry != null) {
        if (entry.persianTranslations.isEmpty) {
          print('[DictionaryBloc] No translations found for ${event.word}');
          emit(DictionaryEmpty());
        } else {
          print('[DictionaryBloc] Loaded ${entry.persianTranslations.length} translations and ${entry.examples.length} examples');
          emit(DictionaryLoaded(entry));
        }
      } else {
        print('[DictionaryBloc] Entry is null for ${event.word}');
        emit(DictionaryEmpty());
      }
    } catch (e) {
      print('[DictionaryBloc] Error: $e');
      emit(DictionaryError("خطا در دریافت اطلاعات"));
    }
  }
}
