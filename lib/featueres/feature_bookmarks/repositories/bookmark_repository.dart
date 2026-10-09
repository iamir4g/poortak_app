import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poortak/common/error_handling/app_exception.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_bookmarks/data/data_source/bookmark_api_provider.dart';
import 'package:poortak/featueres/feature_bookmarks/data/models/bookmark_models.dart';

class BookmarkRepository {
  final BookmarkApiProvider apiProvider;

  final Map<String, String> _bookmarkIds = {};
  final Map<String, bool> _bookmarkedFlags = {};

  BookmarkRepository(this.apiProvider);

  static String cacheKey(BookmarkType type, String itemId) =>
      '${type.apiValue}|$itemId';

  bool isBookmarked(BookmarkType type, String itemId) {
    return _bookmarkedFlags[cacheKey(type, itemId)] ?? false;
  }

  String? bookmarkIdFor(BookmarkType type, String itemId) {
    return _bookmarkIds[cacheKey(type, itemId)];
  }

  void applyDetailFlag({
    required BookmarkType type,
    required String itemId,
    required bool isBookmarked,
    String? bookmarkId,
  }) {
    final key = cacheKey(type, itemId);
    _bookmarkedFlags[key] = isBookmarked;
    if (bookmarkId != null && bookmarkId.isNotEmpty) {
      _bookmarkIds[key] = bookmarkId;
    } else if (!isBookmarked) {
      _bookmarkIds.remove(key);
    }
  }

  void clear() {
    _bookmarkIds.clear();
    _bookmarkedFlags.clear();
  }

  Future<DataState<BookmarksPage>> fetchBookmarks({
    int page = 1,
    int size = 10,
    BookmarkType? type,
  }) async {
    try {
      final response = await apiProvider.fetchBookmarks(
        page: page,
        size: size,
        type: type,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 400) {
        return DataFailed(_errorMessage(response.data, 'خطا در دریافت علاقه‌مندی‌ها'));
      }

      final raw = response.data;
      if (raw is! Map) {
        return const DataFailed('پاسخ نامعتبر از سرور');
      }

      final data = raw.cast<String, dynamic>();
      if (data['ok'] != true) {
        return DataFailed(_errorMessage(data, 'خطا در دریافت علاقه‌مندی‌ها'));
      }

      final list = data['data'] is List ? data['data'] as List : const [];
      final items = list
          .whereType<Map>()
          .map((e) => BookmarkItem.fromJson(e.cast<String, dynamic>()))
          .toList();

      for (final item in items) {
        applyDetailFlag(
          type: item.type,
          itemId: item.itemId,
          isBookmarked: true,
          bookmarkId: item.id,
        );
      }

      final meta = data['meta'] is Map
          ? (data['meta'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      final count = _asInt(meta['count']) ?? items.length;

      return DataSuccess(BookmarksPage(items: items, totalCount: count));
    } on UnauthorisedException catch (e) {
      return DataFailed(e.message ?? 'لطفا وارد حساب کاربری شوید',
          errorCode: 'unauthorized');
    } on DioException catch (e) {
      return DataFailed(_dioErrorMessage(e, 'خطا در دریافت علاقه‌مندی‌ها'));
    } catch (e) {
      log('❌ fetchBookmarks: $e');
      return DataFailed(e.toString());
    }
  }

  Future<DataState<BookmarkItem?>> addBookmark({
    required String itemId,
    required BookmarkType type,
  }) async {
    try {
      final response = await apiProvider.addBookmark(
        itemId: itemId,
        type: type,
      );

      final status = response.statusCode ?? 0;
      final raw = response.data;

      if (status == 201 || status == 200) {
        final item = _parseBookmarkFromResponse(raw);
        applyDetailFlag(
          type: type,
          itemId: itemId,
          isBookmarked: true,
          bookmarkId: item?.id,
        );
        return DataSuccess(item);
      }

      if (status == 422) {
        // alreadyExists → treat as success
        applyDetailFlag(type: type, itemId: itemId, isBookmarked: true);
        final item = _parseBookmarkFromResponse(raw);
        if (item != null) {
          applyDetailFlag(
            type: type,
            itemId: itemId,
            isBookmarked: true,
            bookmarkId: item.id,
          );
        }
        return DataSuccess(item);
      }

      return DataFailed(_errorMessage(raw, 'خطا در ذخیره علاقه‌مندی'));
    } on UnauthorisedException catch (e) {
      return DataFailed(e.message ?? 'لطفا وارد حساب کاربری شوید',
          errorCode: 'unauthorized');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 422) {
        applyDetailFlag(type: type, itemId: itemId, isBookmarked: true);
        final item = _parseBookmarkFromResponse(e.response?.data);
        if (item != null) {
          applyDetailFlag(
            type: type,
            itemId: itemId,
            isBookmarked: true,
            bookmarkId: item.id,
          );
        }
        return DataSuccess(item);
      }
      return DataFailed(_dioErrorMessage(e, 'خطا در ذخیره علاقه‌مندی'));
    } catch (e) {
      log('❌ addBookmark: $e');
      return DataFailed(e.toString());
    }
  }

  Future<DataState<bool>> removeBookmark({
    required String itemId,
    required BookmarkType type,
  }) async {
    try {
      var bookmarkId = bookmarkIdFor(type, itemId);
      if (bookmarkId == null || bookmarkId.isEmpty) {
        bookmarkId = await _resolveBookmarkId(itemId: itemId, type: type);
      }

      if (bookmarkId == null || bookmarkId.isEmpty) {
        applyDetailFlag(type: type, itemId: itemId, isBookmarked: false);
        return const DataSuccess(true);
      }

      final response = await apiProvider.removeBookmark(bookmarkId);
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        applyDetailFlag(type: type, itemId: itemId, isBookmarked: false);
        return const DataSuccess(true);
      }

      return DataFailed(
          _errorMessage(response.data, 'خطا در حذف از علاقه‌مندی‌ها'));
    } on UnauthorisedException catch (e) {
      return DataFailed(e.message ?? 'لطفا وارد حساب کاربری شوید',
          errorCode: 'unauthorized');
    } on DioException catch (e) {
      // Idempotent delete — treat 404 as success
      if (e.response?.statusCode == 404) {
        applyDetailFlag(type: type, itemId: itemId, isBookmarked: false);
        return const DataSuccess(true);
      }
      return DataFailed(_dioErrorMessage(e, 'خطا در حذف از علاقه‌مندی‌ها'));
    } catch (e) {
      log('❌ removeBookmark: $e');
      return DataFailed(e.toString());
    }
  }

  Future<String?> _resolveBookmarkId({
    required String itemId,
    required BookmarkType type,
  }) async {
    final page = await fetchBookmarks(page: 1, size: 50, type: type);
    if (page is! DataSuccess<BookmarksPage> || page.data == null) {
      return null;
    }
    for (final item in page.data!.items) {
      if (item.itemId == itemId) return item.id;
    }
    return bookmarkIdFor(type, itemId);
  }

  BookmarkItem? _parseBookmarkFromResponse(dynamic raw) {
    if (raw is! Map) return null;
    final data = raw.cast<String, dynamic>();
    final payload = data['data'];
    if (payload is Map) {
      return BookmarkItem.fromJson(payload.cast<String, dynamic>());
    }
    return null;
  }

  String _errorMessage(dynamic data, String fallback) {
    // Keep fixed Persian copy for UI; do not surface raw server messages.
    return fallback;
  }

  String _dioErrorMessage(DioException e, String fallback) {
    return _errorMessage(e.response?.data, fallback);
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
