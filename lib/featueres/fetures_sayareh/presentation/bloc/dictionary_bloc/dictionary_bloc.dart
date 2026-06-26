import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/dictionary_repository.dart';
import 'package:poortak/locator.dart';
import 'dictionary_event.dart';
import 'dictionary_state.dart';

class DictionaryBloc extends Bloc<DictionaryEvent, DictionaryState> {
  final DictionaryRepository _repository;
  String _latestSuggestionQuery = '';

  DictionaryBloc({DictionaryRepository? repository})
      : _repository = repository ?? locator<DictionaryRepository>(),
        super(DictionaryInitial()) {
    on<SearchWord>(_onSearchWord);
    on<FetchSuggestions>(_onFetchSuggestions);
  }

  Future<void> _onFetchSuggestions(
    FetchSuggestions event,
    Emitter<DictionaryState> emit,
  ) async {
    final query = event.query.trim();
    if (query.length < 2) {
      _latestSuggestionQuery = '';
      emit(DictionaryInitial());
      return;
    }

    _latestSuggestionQuery = query;
    emit(DictionaryLoading());

    try {
      final suggestions = await _repository.suggestWords(query);
      if (query != _latestSuggestionQuery) return;

      if (suggestions.isEmpty) {
        emit(DictionaryEmpty());
      } else {
        emit(DictionarySuggestionsLoaded(
          query: query,
          suggestions: suggestions,
        ));
      }
    } catch (e) {
      if (query != _latestSuggestionQuery) return;
      print('[DictionaryBloc] Suggest error: $e');
      emit(DictionaryError('خطا در دریافت پیشنهادات'));
    }
  }

  Future<void> _onSearchWord(
    SearchWord event,
    Emitter<DictionaryState> emit,
  ) async {
    final word = event.word.trim();
    if (word.isEmpty) {
      emit(DictionaryInitial());
      return;
    }

    emit(DictionaryLoading());

    try {
      print('[DictionaryBloc] Searching word: $word');
      final entry = await _repository.searchWord(word);
      if (entry != null) {
        if (entry.persianTranslations.isEmpty) {
          print('[DictionaryBloc] No translations found for $word');
          emit(DictionaryEmpty());
        } else {
          print(
              '[DictionaryBloc] Loaded ${entry.persianTranslations.length} translations and ${entry.examples.length} examples');
          emit(DictionaryLoaded(entry));
        }
      } else {
        print('[DictionaryBloc] Entry is null for $word');
        emit(DictionaryEmpty());
      }
    } catch (e) {
      print('[DictionaryBloc] Error: $e');
      emit(DictionaryError("خطا در دریافت اطلاعات"));
    }
  }
}
