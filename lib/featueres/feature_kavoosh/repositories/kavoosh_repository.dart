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
        return DataFailed(
            data['message']?.toString() ?? "خطا در دریافت دسته‌بندی‌ها");
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

  Future<DataState<CategoryNodeSummary>> fetchCategoryNodeContent({
    required String categoryId,
  }) async {
    try {
      final response = await apiProvider.callGetCategoryNodeContent(
        categoryId: categoryId,
      );

      final data = response.data;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data is Map<String, dynamic> &&
          data['ok'] == true) {
        final nodeJson = data['data'];
        if (nodeJson is Map<String, dynamic>) {
          return DataSuccess(CategoryNodeSummary.fromJson(nodeJson));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      if (data is Map<String, dynamic>) {
        return DataFailed(
            data['message']?.toString() ?? "خطا در دریافت محتوای دسته‌بندی");
      }

      return const DataFailed("خطا در دریافت محتوای دسته‌بندی");
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

  Future<DataState<Map<String, dynamic>>> fetchCategoryItems({
    required KavooshTreeType treeType,
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String query = '',
  }) async {
    try {
      final Response response;
      if (treeType == KavooshTreeType.video) {
        response = await apiProvider.callGetVideoCoursesByCategory(
          categoryId: categoryId,
          size: size,
          page: page,
          order: order,
          query: query,
        );
      } else {
        response = await apiProvider.callGetBooksByCategory(
          categoryId: categoryId,
          size: size,
          page: page,
          order: order,
          query: query,
        );
      }

      final data = response.data;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data is Map<String, dynamic> &&
          data['ok'] == true) {
        final items = data['data'];
        final meta = data['meta'];
        return DataSuccess({
          'meta':
              meta is Map ? meta.cast<String, dynamic>() : <String, dynamic>{},
          'data': items is List
              ? items
                  .whereType<Map>()
                  .map((e) => e.cast<String, dynamic>())
                  .toList()
              : <Map<String, dynamic>>[],
        });
      }

      if (data is Map<String, dynamic>) {
        return DataFailed(
            data['message']?.toString() ?? "خطا در دریافت لیست محتوا");
      }

      return const DataFailed("خطا در دریافت لیست محتوا");
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
