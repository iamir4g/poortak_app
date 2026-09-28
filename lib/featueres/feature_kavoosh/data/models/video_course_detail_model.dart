class VideoCourseDetailResponse {
  final VideoCourseInfo course;
  final List<VideoCourseLesson> lessons;

  VideoCourseDetailResponse({
    required this.course,
    required this.lessons,
  });

  factory VideoCourseDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;

    final courseJson = (data['course'] as Map?)?.cast<String, dynamic>() ?? {};
    final lessonsJson = data['lessons'] as List? ?? const [];

    final lessons = lessonsJson
        .whereType<Map>()
        .map((e) => VideoCourseLesson.fromJson(e.cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return VideoCourseDetailResponse(
      course: VideoCourseInfo.fromJson(courseJson),
      lessons: lessons,
    );
  }
}

class VideoCourseInfo {
  final String id;
  final String title;
  final String description;
  final String price;
  final String? thumbnailId;
  final String? instructorId;
  final int totalDuration;
  final String categoryId;
  final int order;
  final bool purchased;
  final bool hasAccess;
  final DateTime? publishedAt;

  VideoCourseInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.totalDuration,
    required this.categoryId,
    required this.order,
    this.thumbnailId,
    this.instructorId,
    this.purchased = false,
    this.hasAccess = false,
    this.publishedAt,
  });

  factory VideoCourseInfo.fromJson(Map<String, dynamic> json) {
    return VideoCourseInfo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      thumbnailId: _nullableString(json['thumbnailId']),
      instructorId: _nullableString(json['instructorId']),
      totalDuration: _asInt(json['totalDuration']),
      categoryId: json['categoryId']?.toString() ?? '',
      order: _asInt(json['order']),
      purchased: _asBool(json['purchased']),
      hasAccess: _asBool(json['hasAccess'] ?? json['access']),
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
    );
  }
}

class VideoCourseLesson {
  final String id;
  final String courseId;
  final String title;
  final bool isFree;
  final String? description;
  final String? fileId;
  final String? thumbnailId;
  final int duration;
  final int order;

  VideoCourseLesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.isFree,
    required this.duration,
    required this.order,
    this.description,
    this.fileId,
    this.thumbnailId,
  });

  factory VideoCourseLesson.fromJson(Map<String, dynamic> json) {
    return VideoCourseLesson(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      isFree: json['isFree'] == true,
      description: _nullableString(json['description']),
      fileId: _nullableString(json['fileId']),
      thumbnailId: _nullableString(json['thumbnailId']),
      duration: _asInt(json['duration']),
      order: _asInt(json['order']),
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
