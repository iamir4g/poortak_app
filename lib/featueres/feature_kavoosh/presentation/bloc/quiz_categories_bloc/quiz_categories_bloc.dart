import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/quiz_models.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';

part 'quiz_categories_event.dart';
part 'quiz_categories_state.dart';

class QuizCategoriesBloc
    extends Bloc<QuizCategoriesEvent, QuizCategoriesState> {
  final KavooshRepository repository;

  QuizCategoriesBloc({required this.repository})
      : super(QuizCategoriesInitial()) {
    on<FetchQuizCategoriesEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchQuizCategoriesEvent event,
    Emitter<QuizCategoriesState> emit,
  ) async {
    emit(QuizCategoriesLoading());

    final result = await repository.fetchQuizCategories();

    if (result is DataSuccess) {
      emit(QuizCategoriesLoaded(result.data ?? const []));
    } else if (result is DataFailed) {
      emit(QuizCategoriesError(
        result.error ?? 'خطا در دریافت دسته‌بندی آزمون‌ها',
      ));
    }
  }
}
