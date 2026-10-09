enum BookmarkType {
  Book,
  VideoCourse,
  IKnowCourse,
  IKnowBook;

  String get apiValue => name;

  static BookmarkType? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final value in BookmarkType.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

class BookmarkItem {
  final String id;
  final BookmarkType type;
  final String itemId;
  final String userId;
  final DateTime createdAt;
  final String displayTitle;
  final String? displayThumbnailId;
  final String? price;
  final String? description;

  const BookmarkItem({
    required this.id,
    required this.type,
    required this.itemId,
    required this.userId,
    required this.createdAt,
    required this.displayTitle,
    this.displayThumbnailId,
    this.price,
    this.description,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    final type = BookmarkType.tryParse(json['type']?.toString()) ??
        BookmarkType.Book;
    final itemMap = json['item'] is Map
        ? (json['item'] as Map).cast<String, dynamic>()
        : null;
    final normalized = _normalizeItem(type, itemMap);

    return BookmarkItem(
      id: json['id']?.toString() ?? '',
      type: type,
      itemId: json['itemId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      displayTitle: normalized.title,
      displayThumbnailId: normalized.thumbnailId,
      price: normalized.price,
      description: normalized.description,
    );
  }
}

class _NormalizedItem {
  final String title;
  final String? thumbnailId;
  final String? price;
  final String? description;

  const _NormalizedItem({
    required this.title,
    this.thumbnailId,
    this.price,
    this.description,
  });
}

_NormalizedItem _normalizeItem(
  BookmarkType type,
  Map<String, dynamic>? item,
) {
  if (item == null) {
    return const _NormalizedItem(title: 'محصول');
  }

  switch (type) {
    case BookmarkType.Book:
    case BookmarkType.VideoCourse:
      return _NormalizedItem(
        title: item['title']?.toString() ?? 'محصول',
        thumbnailId: _nonEmpty(item['thumbnailId']?.toString()),
        price: item['price']?.toString(),
        description: item['description']?.toString(),
      );
    case BookmarkType.IKnowCourse:
      final videoThumb = _nonEmpty(item['videoThumbnail']?.toString());
      final thumb = _nonEmpty(item['thumbnail']?.toString());
      return _NormalizedItem(
        title: item['name']?.toString() ?? 'محصول',
        thumbnailId: videoThumb ?? thumb,
        price: item['price']?.toString(),
        description: item['description']?.toString(),
      );
    case BookmarkType.IKnowBook:
      return _NormalizedItem(
        title: item['title']?.toString() ?? 'محصول',
        thumbnailId: _nonEmpty(item['thumbnail']?.toString()),
        price: item['price']?.toString(),
        description: item['description']?.toString(),
      );
  }
}

String? _nonEmpty(String? value) {
  if (value == null || value.isEmpty) return null;
  return value;
}

class BookmarksPage {
  final List<BookmarkItem> items;
  final int totalCount;

  const BookmarksPage({
    required this.items,
    required this.totalCount,
  });
}
