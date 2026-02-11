import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/feature_litner/repositories/litner_repository.dart';

class LitnerBloc extends Bloc<LitnerEvent, LitnerState> {
  final LitnerRepository litnerRepository;

  LitnerBloc({required this.litnerRepository}) : super(LitnerInitial()) {
    on<CreateWordEvent>(_onCreateWord);
    on<ReviewWordsEvent>(_onReviewWords);
    on<SubmitReviewWordEvent>(_onSubmitReviewWord);
    on<FetchListWordsEvent>(_onFetchListWords);
    on<FetchOverviewLitnerEvent>(_onFetchOverviewLitner);
  }

  Future<void> _onCreateWord(
      CreateWordEvent event, Emitter<LitnerState> emit) async {
    emit(LitnerLoading());

    final result = await litnerRepository.fetchLitnerCreateWord(
      event.word,
      event.translation,
    );

    if (result is DataSuccess) {
      emit(CreateWordSuccess(result.data!));
    } else if (result is DataFailed) {
      String errorMessage = result.error ?? "خطا در ایجاد کلمه";
      if (errorMessage == "این لغت قبلا اضافه شده") {
        errorMessage = "این کلمه قبلا اضافه شده";
      }
      emit(LitnerError(errorMessage));
    }
  }

  Future<void> _onReviewWords(
      ReviewWordsEvent event, Emitter<LitnerState> emit) async {
    emit(LitnerLoading());

    final result = await litnerRepository.fetchLitnerReviewWords();

    if (result is DataSuccess) {
      emit(ReviewWordsSuccess(result.data!));
    } else if (result is DataFailed) {
      emit(LitnerError(result.error ?? "خطا در دریافت کلمات"));
    }
  }

  Future<void> _onSubmitReviewWord(
      SubmitReviewWordEvent event, Emitter<LitnerState> emit) async {
    emit(LitnerLoading());

    final result = await litnerRepository.fetchLitnerSubmitReviewWord(
      event.wordId,
      event.success,
    );

    if (result is DataSuccess) {
      emit(SubmitReviewWordSuccess(result.data!));
    } else if (result is DataFailed) {
      emit(LitnerError(result.error ?? "خطا در ثبت بررسی"));
    }
  }

  Future<void> _onFetchListWords(
      FetchListWordsEvent event, Emitter<LitnerState> emit) async {
    emit(LitnerLoading());
    final result = await litnerRepository.fetchLitnerListWords(
      event.size,
      event.page,
      event.order,
      event.boxLevels,
      event.word,
      event.query,
    );
    if (result is DataSuccess) {
      emit(ListWordsSuccess(result.data!));
    } else if (result is DataFailed) {
      emit(LitnerError(result.error ?? "خطا در دریافت لیست کلمات"));
    }
  }

  Future<void> _onFetchOverviewLitner(
      FetchOverviewLitnerEvent event, Emitter<LitnerState> emit) async {
    emit(LitnerLoading());
    final result = await litnerRepository.fetchLitnerOverview();
    if (result is DataSuccess) {
      emit(OverviewLitnerSuccess(result.data!));
    } else if (result is DataFailed) {
      emit(LitnerError(result.error ?? "خطا در دریافت اطلاعات لایتنر"));
    }
  }
}
