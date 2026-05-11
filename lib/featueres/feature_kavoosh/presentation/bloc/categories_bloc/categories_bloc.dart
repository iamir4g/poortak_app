import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_event.dart';
import 'package:poortak/featueres/feature_kavoosh/presentation/bloc/categories_bloc/categories_state.dart';
import 'package:poortak/featueres/feature_kavoosh/repositories/kavoosh_repository.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final KavooshRepository repository;

  CategoriesBloc({required this.repository}) : super(CategoriesInitial()) {
    on<FetchCategoryNodesSummaryEvent>(_onFetchCategoryNodesSummary);
    on<FetchCategoryNodeContentEvent>(_onFetchCategoryNodeContent);
  }

  Future<void> _onFetchCategoryNodesSummary(
    FetchCategoryNodesSummaryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());

    final result = await repository.fetchCategoryNodesSummary(
      treeType: event.treeType,
      parentCategoryId: event.parentCategoryId,
    );

    if (result is DataSuccess) {
      emit(CategoriesLoaded(result.data ?? const []));
    } else if (result is DataFailed) {
      emit(CategoriesError(result.error ?? "خطا در دریافت دسته‌بندی‌ها"));
    }
  }

  Future<void> _onFetchCategoryNodeContent(
    FetchCategoryNodeContentEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());

    final result = await repository.fetchCategoryNodeContent(
      categoryId: event.categoryId,
    );

    if (result is DataSuccess) {
      final category = result.data;
      if (category == null) {
        emit(CategoriesError("داده‌ای یافت نشد"));
        return;
      }
      emit(CategoryNodeContentLoaded(category));
    } else if (result is DataFailed) {
      emit(CategoriesError(result.error ?? "خطا در دریافت محتوای دسته‌بندی"));
    }
  }
}
