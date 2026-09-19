import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';

class KavooshApiProvider {
  final Dio dio;

  KavooshApiProvider({required this.dio});

  /// GET /categories/nodes/summary?treeType=&parentCategoryId=
  Future<Response> callGetCategoryNodesSummary({
    required KavooshTreeType treeType,
    String? parentCategoryId,
  }) async {
    final queryParameters = <String, dynamic>{'treeType': treeType.apiValue};
    if (parentCategoryId != null && parentCategoryId.isNotEmpty) {
      queryParameters['parentCategoryId'] = parentCategoryId;
    }

    return dio.get(
      "${Constants.baseUrl}categories/nodes/summary",
      queryParameters: queryParameters,
    );
  }

  /// GET /categories/nodes/:categoryId
  Future<Response> callGetCategoryNodeDetail({
    required String categoryId,
  }) {
    return dio.get(
      "${Constants.baseUrl}categories/nodes/$categoryId",
    );
  }

  /// GET /video-courses/category/:categoryId
  Future<Response> callGetVideoCoursesByCategory({
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String? query,
  }) {
    final queryParameters = <String, dynamic>{
      'size': size,
      'page': page,
      'order': order,
    };
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    return dio.get(
      "${Constants.baseUrl}video-courses/category/$categoryId",
      queryParameters: queryParameters,
    );
  }

  /// GET /books/category/:categoryId
  Future<Response> callGetBooksByCategory({
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String? query,
  }) {
    final queryParameters = <String, dynamic>{
      'size': size,
      'page': page,
      'order': order,
    };
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    return dio.get(
      "${Constants.baseUrl}books/category/$categoryId",
      queryParameters: queryParameters,
    );
  }
}
