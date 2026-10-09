import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/services/auth_service.dart';
import 'package:poortak/config/constants.dart';
import 'package:poortak/featueres/feature_bookmarks/data/models/bookmark_models.dart';
import 'package:poortak/locator.dart';

class BookmarkApiProvider {
  final Dio dio;
  final AuthService _authService;

  BookmarkApiProvider({required this.dio})
      : _authService = locator<AuthService>();

  Future<Response> fetchBookmarks({
    int page = 1,
    int size = 10,
    BookmarkType? type,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (type != null) {
      query['type'] = type.apiValue;
    }

    final response = await _authService.get(
      '${Constants.baseUrl}bookmarks',
      queryParameters: query,
    );
    log('📚 Bookmarks list: ${response.statusCode}');
    return response;
  }

  Future<Response> addBookmark({
    required String itemId,
    required BookmarkType type,
  }) async {
    final response = await _authService.post(
      '${Constants.baseUrl}bookmarks',
      data: {
        'itemId': itemId,
        'type': type.apiValue,
      },
    );
    log('📚 Bookmark add: ${response.statusCode}');
    return response;
  }

  Future<Response> removeBookmark(String bookmarkId) async {
    final response = await _authService.delete(
      '${Constants.baseUrl}bookmarks/$bookmarkId',
    );
    log('📚 Bookmark remove: ${response.statusCode}');
    return response;
  }
}
