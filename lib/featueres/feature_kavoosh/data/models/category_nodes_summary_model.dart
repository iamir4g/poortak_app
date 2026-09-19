class CategoryNodesSummaryResponse {
  final bool ok;
  final Map<String, dynamic> meta;
  final List<CategoryNodeSummary> data;

  CategoryNodesSummaryResponse({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory CategoryNodesSummaryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryNodesSummaryResponse(
      ok: json['ok'] == true,
      meta: (json['meta'] as Map?)?.cast<String, dynamic>() ?? {},
      data: (json['data'] as List? ?? [])
          .map((e) =>
              CategoryNodeSummary.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

/// Shared shape for summary tree nodes and single-category detail.
/// Detail responses additionally populate [parentId].
class CategoryNodeSummary {
  final String id;
  final String title;
  final String description;

  /// One of: CATEGORY | VIDEO | BOOK
  final String type;
  final int order;
  final String? thumbnailId;
  final String? backgroundImageId;
  final int courseCount;
  final int bookCount;

  /// Present on detail endpoint; null means root.
  final String? parentId;
  final List<CategoryNodeSummary> children;

  CategoryNodeSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    required this.courseCount,
    required this.bookCount,
    required this.children,
    this.thumbnailId,
    this.backgroundImageId,
    this.parentId,
  });

  factory CategoryNodeSummary.fromJson(Map<String, dynamic> json) {
    return CategoryNodeSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      order: _asInt(json['order']),
      thumbnailId: _asNullableString(json['thumbnailId']),
      backgroundImageId: _asNullableString(json['backgroundImageId']),
      courseCount: _asInt(json['courseCount']),
      bookCount: _asInt(json['bookCount']),
      parentId: _asNullableString(json['parentId']),
      children: (json['children'] as List? ?? [])
          .map((e) =>
              CategoryNodeSummary.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }
}
