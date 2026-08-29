// To parse this JSON data, do
//
//     final quizesList = quizesListFromJson(jsonString);

import 'dart:convert';

QuizesList quizesListFromJson(String str) =>
    QuizesList.fromJson(json.decode(str));

String quizesListToJson(QuizesList data) => json.encode(data.toJson());

class QuizesList {
  bool ok;
  Meta meta;
  List<Datum> data;

  QuizesList({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory QuizesList.fromJson(Map<String, dynamic> json) => QuizesList(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String id;
  String title;
  String difficulty;
  String thumbnail;
  DateTime createdAt;
  DateTime updatedAt;
  String iKnowCourseId;
  List<IKnowUserQuizProgress> iKnowUserQuizProgresses;

  Datum({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.thumbnail,
    required this.createdAt,
    required this.updatedAt,
    required this.iKnowCourseId,
    required this.iKnowUserQuizProgresses,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        difficulty: json["difficulty"] ?? "",
        thumbnail: json["thumbnail"] ?? "",
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        iKnowCourseId: json["iKnowCourseId"] ?? "",
        iKnowUserQuizProgresses: (json["iKnowUserQuizProgresses"] as List?)
                ?.map((x) => IKnowUserQuizProgress.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "difficulty": difficulty,
        "thumbnail": thumbnail,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "iKnowCourseId": iKnowCourseId,
        "iKnowUserQuizProgresses":
            List<dynamic>.from(iKnowUserQuizProgresses.map((x) => x.toJson())),
      };
}

class IKnowUserQuizProgress {
  String id;
  int score;
  bool completed;
  String quizId;
  String userId;

  IKnowUserQuizProgress({
    required this.id,
    required this.score,
    required this.completed,
    required this.quizId,
    required this.userId,
  });

  factory IKnowUserQuizProgress.fromJson(Map<String, dynamic> json) =>
      IKnowUserQuizProgress(
        id: json["id"] ?? "",
        score: json["score"] ?? 0,
        completed: json["completed"] ?? false,
        quizId: json["quizId"] ?? "",
        userId: json["userId"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "score": score,
        "completed": completed,
        "quizId": quizId,
        "userId": userId,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
