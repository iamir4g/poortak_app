import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryNodeSummary> categories;

  CategoriesLoaded(this.categories);
}

class CategoryNodeContentLoaded extends CategoriesState {
  final CategoryNodeSummary category;

  CategoryNodeContentLoaded(this.category);
}

class CategoryItemsLoaded extends CategoriesState {
  final List<Map<String, dynamic>> items;
  final int count;

  CategoryItemsLoaded({
    required this.items,
    required this.count,
  });
}

class CategoriesError extends CategoriesState {
  final String message;

  CategoriesError(this.message);
}
