import 'dart:convert';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';

AllCoursesProgressModel allCoursesProgressModelFromJson(String str) =>
    AllCoursesProgressModel.fromJson(json.decode(str));

String allCoursesProgressModelToJson(AllCoursesProgressModel data) =>
    json.encode(data.toJson());

class AllCoursesProgressModel {
  bool ok;
  Meta meta;
  List<CourseProgressItem> data;

  AllCoursesProgressModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory AllCoursesProgressModel.fromJson(Map<String, dynamic> json) =>
      AllCoursesProgressModel(
        ok: json["ok"] ?? false,
        meta: Meta.fromJson(json["meta"] ?? {}),
        data: json["data"] != null
            ? List<CourseProgressItem>.from(
                json["data"].map((x) => CourseProgressItem.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CourseProgressItem {
  String id;
  String iKnowCourseId;
  String userId;
  int vocabulary;
  int conversation;
  int quiz;
  DateTime createdAt;
  DateTime updatedAt;

  CourseProgressItem({
    required this.id,
    required this.iKnowCourseId,
    required this.userId,
    required this.vocabulary,
    required this.conversation,
    required this.quiz,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseProgressItem.fromJson(Map<String, dynamic> json) =>
      CourseProgressItem(
        id: json["id"] ?? "",
        iKnowCourseId: json["iKnowCourseId"] ?? "",
        userId: json["userId"] ?? "",
        vocabulary: json["vocabulary"] ?? 0,
        conversation: json["conversation"] ?? 0,
        quiz: json["quiz"] ?? 0,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "iKnowCourseId": iKnowCourseId,
        "userId": userId,
        "vocabulary": vocabulary,
        "conversation": conversation,
        "quiz": quiz,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
