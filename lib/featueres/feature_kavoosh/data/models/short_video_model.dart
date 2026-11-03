class ShortVideoCategory {
  final String id;
  final String title;
  final String type;
  final int order;

  const ShortVideoCategory({
    required this.id,
    required this.title,
    required this.type,
    required this.order,
  });

  factory ShortVideoCategory.fromJson(Map<String, dynamic> json) {
    return ShortVideoCategory(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      order: _asInt(json['order']),
    );
  }
}

class ShortVideoInstructor {
  final String id;
  final String name;

  const ShortVideoInstructor({
    required this.id,
    required this.name,
  });

  factory ShortVideoInstructor.fromJson(Map<String, dynamic> json) {
    final first = _nullableString(json['firstName']);
    final last = _nullableString(json['lastName']);
    final combined = [first, last].whereType<String>().join(' ').trim();

    return ShortVideoInstructor(
      id: json['id']?.toString() ?? '',
      name: _nullableString(json['name']) ??
          _nullableString(json['fullName']) ??
          _nullableString(json['title']) ??
          (combined.isEmpty ? '' : combined),
    );
  }
}

class ShortVideoSummary {
  final String id;
  final String title;
  final String fileId;
  final String thumbnailId;
  final String categoryId;
  final ShortVideoCategory? category;
  final String? instructorId;
  final ShortVideoInstructor? instructor;
  final int duration;
  final int order;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShortVideoSummary({
    required this.id,
    required this.title,
    required this.fileId,
    required this.thumbnailId,
    required this.categoryId,
    required this.duration,
    required this.order,
    this.category,
    this.instructorId,
    this.instructor,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ShortVideoSummary.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    final instructorJson = json['instructor'];

    return ShortVideoSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      fileId: json['fileId']?.toString() ?? '',
      thumbnailId: json['thumbnailId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      category: categoryJson is Map
          ? ShortVideoCategory.fromJson(categoryJson.cast<String, dynamic>())
          : null,
      instructorId: _nullableString(json['instructorId']),
      instructor: instructorJson is Map
          ? ShortVideoInstructor.fromJson(
              instructorJson.cast<String, dynamic>(),
            )
          : null,
      duration: _asInt(json['duration']),
      order: _asInt(json['order']),
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class ShortVideoDetail extends ShortVideoSummary {
  final String? description;
  final bool isBookmarked;

  const ShortVideoDetail({
    required super.id,
    required super.title,
    required super.fileId,
    required super.thumbnailId,
    required super.categoryId,
    required super.duration,
    required super.order,
    super.category,
    super.instructorId,
    super.instructor,
    super.publishedAt,
    super.createdAt,
    super.updatedAt,
    this.description,
    this.isBookmarked = false,
  });

  factory ShortVideoDetail.fromJson(Map<String, dynamic> json) {
    final summary = ShortVideoSummary.fromJson(json);
    return ShortVideoDetail(
      id: summary.id,
      title: summary.title,
      fileId: summary.fileId,
      thumbnailId: summary.thumbnailId,
      categoryId: summary.categoryId,
      category: summary.category,
      instructorId: summary.instructorId,
      instructor: summary.instructor,
      duration: summary.duration,
      order: summary.order,
      publishedAt: summary.publishedAt,
      createdAt: summary.createdAt,
      updatedAt: summary.updatedAt,
      description: _nullableString(json['description']),
      isBookmarked: json['isBookmarked'] == true,
    );
  }
}

class ShortVideoPage {
  final List<ShortVideoSummary> items;
  final int totalCount;

  const ShortVideoPage({
    required this.items,
    required this.totalCount,
  });
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty || text == 'null') return null;
  return text;
}
