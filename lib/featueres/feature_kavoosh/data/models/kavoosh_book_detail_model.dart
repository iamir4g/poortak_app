class KavooshBookDetail {
  final String id;
  final String title;
  final String authorName;
  final String publisher;
  final String description;
  final String price;
  final String publishDate;
  final String format;
  final int size;
  final int pages;
  final int order;
  final int userPointsAfterPurchase;
  final String categoryId;
  final String? fileId;
  final String? demoFileId;
  final String? thumbnailId;
  final bool purchased;
  final bool hasAccess;
  final DateTime? publishedAt;
  final KavooshBookCategory? category;

  KavooshBookDetail({
    required this.id,
    required this.title,
    required this.authorName,
    required this.publisher,
    required this.description,
    required this.price,
    required this.publishDate,
    required this.format,
    required this.size,
    required this.pages,
    required this.order,
    required this.userPointsAfterPurchase,
    required this.categoryId,
    this.fileId,
    this.demoFileId,
    this.thumbnailId,
    this.purchased = false,
    this.hasAccess = false,
    this.publishedAt,
    this.category,
  });

  factory KavooshBookDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;

    return KavooshBookDetail(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      authorName: data['authorName']?.toString() ?? '',
      publisher: data['publisher']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      price: data['price']?.toString() ?? '0',
      publishDate: data['publishDate']?.toString() ?? '',
      format: data['format']?.toString() ?? '',
      size: _asInt(data['size']),
      pages: _asInt(data['pages']),
      order: _asInt(data['order']),
      userPointsAfterPurchase: _asInt(data['userPointsAfterPurchase']),
      categoryId: data['categoryId']?.toString() ?? '',
      fileId: _nullableString(data['fileId'] ?? data['file']),
      demoFileId: _nullableString(data['demoFileId'] ?? data['trialFile']),
      thumbnailId: _nullableString(data['thumbnailId']),
      purchased: _asBool(data['purchased']),
      hasAccess: _asBool(data['hasAccess'] ?? data['access']),
      publishedAt: DateTime.tryParse(data['publishedAt']?.toString() ?? ''),
      category: data['category'] is Map
          ? KavooshBookCategory.fromJson(
              (data['category'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }

  String get formatLabel {
    final lower = format.toLowerCase();
    if (lower.contains('pdf')) return 'PDF';
    if (format.contains('/')) {
      final parts = format.split('/');
      return parts.last.toUpperCase();
    }
    return format.isEmpty ? '—' : format;
  }
}

class KavooshBookCategory {
  final String id;
  final String title;
  final String? parentId;

  KavooshBookCategory({
    required this.id,
    required this.title,
    this.parentId,
  });

  factory KavooshBookCategory.fromJson(Map<String, dynamic> json) {
    return KavooshBookCategory(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      parentId: _nullableString(json['parentId']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty || text == 'null') return null;
  return text;
}
