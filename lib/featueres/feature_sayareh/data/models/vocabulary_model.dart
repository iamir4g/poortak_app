// To parse this JSON data, do
//
//     final vocabularyModel = vocabularyModelFromJson(jsonString);

import 'dart:convert';

VocabularyModel vocabularyModelFromJson(String str) =>
    VocabularyModel.fromJson(json.decode(str));

String vocabularyModelToJson(VocabularyModel data) =>
    json.encode(data.toJson());

class VocabularyModel {
  bool ok;
  Meta meta;
  List<Vocabulary> data;

  VocabularyModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) =>
      VocabularyModel(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: List<Vocabulary>.from(
            json["data"].map((x) => Vocabulary.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Vocabulary {
  String id;
  String word;
  String translation;
  String thumbnail;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic disabledAt;
  String courseId;

  Vocabulary({
    required this.id,
    required this.word,
    required this.translation,
    required this.thumbnail,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.disabledAt,
    required this.courseId,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) => Vocabulary(
        id: json["id"],
        word: json["word"],
        translation: json["translation"],
        thumbnail: json["thumbnail"],
        order: json["order"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        disabledAt: json["disabledAt"],
        courseId: json["courseId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "word": word,
        "translation": translation,
        "thumbnail": thumbnail,
        "order": order,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "disabledAt": disabledAt,
        "courseId": courseId,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
