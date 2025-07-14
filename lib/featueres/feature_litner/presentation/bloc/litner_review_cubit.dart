import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/featueres/feature_litner/data/models/review_words_model.dart';
import 'package:poortak/featueres/feature_litner/repositories/litner_repository.dart';
import 'package:poortak/common/resources/data_state.dart';

// States
abstract class LitnerReviewState {}

class LitnerReviewInitial extends LitnerReviewState {}

class LitnerReviewLoading extends LitnerReviewState {}

class LitnerReviewLoaded extends LitnerReviewState {
  final List<Datum> words;
  final int currentIndex;

  LitnerReviewLoaded({required this.words, required this.currentIndex});
}

class LitnerReviewError extends LitnerReviewState {
  final String message;
  LitnerReviewError(this.message);
}

// Cubit
class LitnerReviewCubit extends Cubit<LitnerReviewState> {
  final LitnerRepository repository;
  List<Datum> _words = [];
  int _currentIndex = 0;

  LitnerReviewCubit(this.repository) : super(LitnerReviewInitial());

  Future<void> fetchWords() async {
    emit(LitnerReviewLoading());
    final result = await repository.fetchLitnerReviewWords();
    if (result is DataSuccess<ReviewWords>) {
      _words = result.data!.data; // 'data' is the list of Datum
      _currentIndex = 0;
      emit(LitnerReviewLoaded(words: _words, currentIndex: _currentIndex));
    } else {
      emit(LitnerReviewError(result.error ?? "خطا در دریافت اطلاعات"));
    }
  }

  void nextWord() {
    if (_currentIndex < _words.length - 1) {
      _currentIndex++;
      emit(LitnerReviewLoaded(words: _words, currentIndex: _currentIndex));
    }
    // Optionally handle end of list
  }

  void previousWord() {
    if (_currentIndex > 0) {
      _currentIndex--;
      emit(LitnerReviewLoaded(words: _words, currentIndex: _currentIndex));
    }
  }

  Future<void> submitReviewAndNext(String wordId, bool success) async {
    try {
      await repository.fetchLitnerSubmitReviewWord(wordId, success);
    } catch (e) {
      // Optionally handle error (e.g., show a snackbar)
    }
    nextWord();
  }
}
