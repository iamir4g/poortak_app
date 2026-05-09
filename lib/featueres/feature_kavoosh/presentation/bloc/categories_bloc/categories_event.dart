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
