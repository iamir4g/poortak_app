import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
 
abstract class CategoriesState {}
 
class CategoriesInitial extends CategoriesState {}
 
class CategoriesLoading extends CategoriesState {}
 
class CategoriesLoaded extends CategoriesState {
  final List<CategoryNodeSummary> categories;
 
  CategoriesLoaded(this.categories);
}
 
class CategoriesError extends CategoriesState {
  final String message;
 
  CategoriesError(this.message);
}
