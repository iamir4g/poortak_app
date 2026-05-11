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
    on<FetchCategoryItemsEvent>(_onFetchCategoryItems);
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

  Future<void> _onFetchCategoryItems(
    FetchCategoryItemsEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());

    final result = await repository.fetchCategoryItems(
      treeType: event.treeType,
      categoryId: event.categoryId,
      size: event.size,
      page: event.page,
      order: event.order,
      query: event.query,
    );

    if (result is DataSuccess) {
      final payload = result.data ?? const <String, dynamic>{};
      final meta = payload['meta'];
      final data = payload['data'];
      final countRaw = meta is Map
          ? meta['count']
          : (payload['count'] ?? payload['metaCount']);
      final count = countRaw is int
          ? countRaw
          : int.tryParse(countRaw?.toString() ?? '') ?? 0;

      emit(CategoryItemsLoaded(
        items: data is List
            ? data
                .whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList()
            : const [],
        count: count,
      ));
    } else if (result is DataFailed) {
      emit(CategoriesError(result.error ?? "خطا در دریافت لیست محتوا"));
    }
  }
}
