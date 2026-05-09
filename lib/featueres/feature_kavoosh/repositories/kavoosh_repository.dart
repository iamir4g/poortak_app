import 'package:dio/dio.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_kavoosh/data/data_source/kavoosh_api_provider.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/category_nodes_summary_model.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';
 
class KavooshRepository {
  final KavooshApiProvider apiProvider;
 
  KavooshRepository(this.apiProvider);
 
  Future<DataState<List<CategoryNodeSummary>>> fetchCategoryNodesSummary({
    required KavooshTreeType treeType,
    String? parentCategoryId,
  }) async {
    try {
      final response = await apiProvider.callGetCategoryNodesSummary(
        treeType: treeType,
        parentCategoryId: parentCategoryId,
      );
 
      final data = response.data;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data is Map<String, dynamic> &&
          data['ok'] == true) {
        final parsed = CategoryNodesSummaryResponse.fromJson(data);
        return DataSuccess(parsed.data);
      }
 
      if (data is Map<String, dynamic>) {
        return DataFailed(data['message']?.toString() ?? "خطا در دریافت دسته‌بندی‌ها");
      }
 
      return const DataFailed("خطا در دریافت دسته‌بندی‌ها");
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return DataFailed(message);
        }
      }
      return DataFailed(e.message ?? "خطا در اتصال به سرور");
    } catch (e) {
      return DataFailed(e.toString());
    }
  }
}
