import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/resources/data_state.dart';
import 'package:poortak/featueres/feature_bookmarks/data/models/bookmark_models.dart';
import 'package:poortak/featueres/feature_bookmarks/repositories/bookmark_repository.dart';

class BookmarkState {
  final Map<String, bool> bookmarkedByKey;
  final List<BookmarkItem> favorites;
  final int totalCount;
  final int currentPage;
  final bool isLoadingList;
  final bool isLoadingMore;
  final bool hasMore;
  final String? listError;
  final String? actionError;
  final String? actionErrorCode;

  const BookmarkState({
    this.bookmarkedByKey = const {},
    this.favorites = const [],
    this.totalCount = 0,
    this.currentPage = 0,
    this.isLoadingList = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.listError,
    this.actionError,
    this.actionErrorCode,
  });

  bool isBookmarked(BookmarkType type, String itemId) {
    return bookmarkedByKey[BookmarkRepository.cacheKey(type, itemId)] ?? false;
  }

  BookmarkState copyWith({
    Map<String, bool>? bookmarkedByKey,
    List<BookmarkItem>? favorites,
    int? totalCount,
    int? currentPage,
    bool? isLoadingList,
    bool? isLoadingMore,
    bool? hasMore,
    String? listError,
    bool clearListError = false,
    String? actionError,
    bool clearActionError = false,
    String? actionErrorCode,
    bool clearActionErrorCode = false,
  }) {
    return BookmarkState(
      bookmarkedByKey: bookmarkedByKey ?? this.bookmarkedByKey,
      favorites: favorites ?? this.favorites,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      listError: clearListError ? null : (listError ?? this.listError),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      actionErrorCode: clearActionErrorCode
          ? null
          : (actionErrorCode ?? this.actionErrorCode),
    );
  }
}

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository repository;
  static const int pageSize = 10;

  BookmarkCubit({required this.repository}) : super(const BookmarkState());

  Map<String, bool> _snapshotFlags() {
    // Rebuild from repository known keys via favorites + previous state
    final map = Map<String, bool>.from(state.bookmarkedByKey);
    return map;
  }

  void syncFromDetail({
    required BookmarkType type,
    required String itemId,
    required bool isBookmarked,
    String? bookmarkId,
  }) {
    repository.applyDetailFlag(
      type: type,
      itemId: itemId,
      isBookmarked: isBookmarked,
      bookmarkId: bookmarkId,
    );
    final key = BookmarkRepository.cacheKey(type, itemId);
    final flags = _snapshotFlags();
    flags[key] = isBookmarked;
    emit(state.copyWith(bookmarkedByKey: flags, clearActionError: true));
  }

  Future<void> loadFavorites({bool refresh = true}) async {
    if (refresh) {
      emit(state.copyWith(
        isLoadingList: true,
        clearListError: true,
        favorites: const [],
        currentPage: 0,
        hasMore: true,
      ));
    } else {
      if (!state.hasMore || state.isLoadingMore || state.isLoadingList) return;
      emit(state.copyWith(isLoadingMore: true, clearListError: true));
    }

    final nextPage = refresh ? 1 : state.currentPage + 1;
    final result = await repository.fetchBookmarks(
      page: nextPage,
      size: pageSize,
    );

    if (result is DataFailed) {
      emit(state.copyWith(
        isLoadingList: false,
        isLoadingMore: false,
        listError: result.error,
      ));
      return;
    }

    final page = (result as DataSuccess<BookmarksPage>).data!;
    final merged = refresh
        ? page.items
        : [...state.favorites, ...page.items];
    final flags = _snapshotFlags();
    for (final item in page.items) {
      flags[BookmarkRepository.cacheKey(item.type, item.itemId)] = true;
    }

    emit(state.copyWith(
      favorites: merged,
      totalCount: page.totalCount,
      currentPage: nextPage,
      hasMore: merged.length < page.totalCount,
      isLoadingList: false,
      isLoadingMore: false,
      bookmarkedByKey: flags,
      clearListError: true,
    ));
  }

  Future<bool> toggle({
    required BookmarkType type,
    required String itemId,
  }) async {
    final key = BookmarkRepository.cacheKey(type, itemId);
    final currentlyBookmarked = state.isBookmarked(type, itemId);
    final flags = _snapshotFlags();
    flags[key] = !currentlyBookmarked;
    emit(state.copyWith(
      bookmarkedByKey: flags,
      clearActionError: true,
      clearActionErrorCode: true,
    ));

    if (currentlyBookmarked) {
      final result = await repository.removeBookmark(
        itemId: itemId,
        type: type,
      );
      if (result is DataFailed) {
        flags[key] = true;
        emit(state.copyWith(
          bookmarkedByKey: Map<String, bool>.from(flags),
          actionError: result.error,
          actionErrorCode: result.errorCode,
        ));
        return false;
      }
      final updatedFavorites =
          state.favorites.where((e) => !(e.itemId == itemId && e.type == type)).toList();
      emit(state.copyWith(
        favorites: updatedFavorites,
        totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
        bookmarkedByKey: Map<String, bool>.from(flags),
      ));
      return true;
    }

    final result = await repository.addBookmark(itemId: itemId, type: type);
    if (result is DataFailed) {
      flags[key] = false;
      emit(state.copyWith(
        bookmarkedByKey: Map<String, bool>.from(flags),
        actionError: result.error,
        actionErrorCode: result.errorCode,
      ));
      return false;
    }

    final added = (result as DataSuccess<BookmarkItem?>).data;
    final favorites = List<BookmarkItem>.from(state.favorites);
    if (added != null &&
        !favorites.any((e) => e.itemId == itemId && e.type == type)) {
      favorites.insert(0, added);
    }
    emit(state.copyWith(
      favorites: favorites,
      totalCount: state.totalCount + (added != null ? 1 : 0),
      bookmarkedByKey: Map<String, bool>.from(flags)..[key] = true,
    ));
    return true;
  }

  Future<bool> removeFavorite(BookmarkItem item) {
    return toggle(type: item.type, itemId: item.itemId);
  }

  void clear() {
    repository.clear();
    emit(const BookmarkState());
  }

  void clearActionError() {
    emit(state.copyWith(clearActionError: true, clearActionErrorCode: true));
  }
}
