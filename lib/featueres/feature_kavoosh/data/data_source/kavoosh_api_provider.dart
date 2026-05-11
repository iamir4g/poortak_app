import 'package:dio/dio.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/kavoosh_tree_type.dart';

class KavooshApiProvider {
  final Dio dio;

  KavooshApiProvider({required this.dio});

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

  Future<Response> callGetCategoryNodeContent({
    required String categoryId,
  }) {
    return dio.get(
      "${Constants.baseUrl}categories/nodes/$categoryId/content",
    );
  }

  Future<Response> callGetVideoCoursesByCategory({
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String query = '',
  }) {
    return dio.get(
      "${Constants.baseUrl}video-courses/category/$categoryId",
      queryParameters: {
        'size': size,
        'page': page,
        'order': order,
        'query': query,
      },
    );
  }

  Future<Response> callGetBooksByCategory({
    required String categoryId,
    int size = 10,
    int page = 1,
    String order = 'asc',
    String query = '',
  }) {
    return dio.get(
      "${Constants.baseUrl}books/category/$categoryId",
      queryParameters: {
        'size': size,
        'page': page,
        'order': order,
        'query': query,
      },
    );
  }
}
