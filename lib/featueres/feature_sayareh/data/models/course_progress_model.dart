class CourseProgressModel {
  bool ok;
  Meta meta;
  CourseProgressData? data;

  CourseProgressModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    // Handle both List (old structure) and Object (new structure) for data
    CourseProgressData? parsedData;

    if (json["data"] != null) {
      if (json["data"] is List) {
        final list = json["data"] as List;
        if (list.isNotEmpty) {
          parsedData = CourseProgressData.fromJson(list.first);
        }
      } else if (json["data"] is Map<String, dynamic>) {
        parsedData = CourseProgressData.fromJson(json["data"]);
      }
    }

    return CourseProgressModel(
      ok: json["ok"],
      meta: Meta.fromJson(json["meta"]),
      data: parsedData,
    );
  }
}

class CourseProgressData {
  String id;
  String iKnowCourseId;
  String userId;
  int vocabulary;
  int conversation;
  int quiz;
  DateTime createdAt;
  DateTime updatedAt;

  CourseProgressData({
    required this.id,
    required this.iKnowCourseId,
    required this.userId,
    required this.vocabulary,
    required this.conversation,
    required this.quiz,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseProgressData.fromJson(Map<String, dynamic> json) =>
      CourseProgressData(
        id: json["id"],
        iKnowCourseId: json["iKnowCourseId"],
        userId: json["userId"],
        vocabulary: json["vocabulary"],
        conversation: json["conversation"],
        quiz: json["quiz"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
