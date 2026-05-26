import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';

abstract class CategoriesEvent {}

class FetchCategoryNodesSummaryEvent extends CategoriesEvent {
  final KavooshTreeType treeType;
  final String? parentCategoryId;

  FetchCategoryNodesSummaryEvent({
    required this.treeType,
    this.parentCategoryId,
  });
}

class FetchCategoryNodeContentEvent extends CategoriesEvent {
  final String categoryId;

  FetchCategoryNodeContentEvent({
    required this.categoryId,
  });
}

class FetchCategoryItemsEvent extends CategoriesEvent {
  final KavooshTreeType treeType;
  final String categoryId;
  final int size;
  final int page;
  final String order;
  final String query;

  FetchCategoryItemsEvent({
    required this.treeType,
    required this.categoryId,
    this.size = 10,
    this.page = 1,
    this.order = 'asc',
    this.query = '',
  });
}
