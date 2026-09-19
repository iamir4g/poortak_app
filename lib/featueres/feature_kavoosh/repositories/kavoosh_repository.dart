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

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت دسته‌بندی‌ها",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final parsed = CategoryNodesSummaryResponse.fromJson(data);
        return DataSuccess(parsed.data);
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت دسته‌بندی‌ها",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت دسته‌بندی‌ها"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  Future<DataState<CategoryNodeSummary>> fetchCategoryNodeDetail({
    required String categoryId,
  }) async {
    try {
      final response = await apiProvider.callGetCategoryNodeDetail(
        categoryId: categoryId,
      );

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت جزئیات دسته‌بندی",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
        final nodeJson = data['data'];
        if (nodeJson is Map<String, dynamic>) {
          return DataSuccess(CategoryNodeSummary.fromJson(nodeJson));
        }
        return const DataFailed("فرمت پاسخ سرور نامعتبر است");
      }

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت جزئیات دسته‌بندی",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت جزئیات دسته‌بندی"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  /// Paginated courses/books for a category (incl. sub-tree).
  /// Returns `{ data: List<Map>, meta: { count } }` until typed list models land.
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

      if (_isHttpFailure(response.statusCode)) {
        return DataFailed(_errorMessage(
          response.data,
          fallback: "خطا در دریافت لیست محتوا",
        ));
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['ok'] == true) {
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

      return DataFailed(_errorMessage(
        data,
        fallback: "خطا در دریافت لیست محتوا",
      ));
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, "خطا در دریافت لیست محتوا"));
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  bool _isHttpFailure(int? statusCode) {
    return statusCode != null && statusCode >= 400;
  }

  String _dioErrorMessage(DioException e, String fallback) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return e.message ?? fallback;
  }

  String _errorMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }
}
