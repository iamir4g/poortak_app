import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/quiz_models.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';

part 'quiz_list_event.dart';
part 'quiz_list_state.dart';

class QuizListBloc extends Bloc<QuizListEvent, QuizListState> {
  final KavooshRepository repository;

  QuizListBloc({required this.repository}) : super(QuizListInitial()) {
    on<FetchQuizListEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchQuizListEvent event,
    Emitter<QuizListState> emit,
  ) async {
    emit(QuizListLoading());

    final result = await repository.fetchCategoryQuizzes(
      categoryId: event.categoryId,
      size: event.size,
      page: event.page,
    );

    if (result is DataSuccess) {
      emit(QuizListLoaded(result.data ?? const []));
    } else if (result is DataFailed) {
      emit(QuizListError(result.error ?? 'خطا در دریافت لیست آزمون‌ها'));
    }
  }
}
