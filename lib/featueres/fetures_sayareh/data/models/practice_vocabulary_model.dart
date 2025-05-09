// To parse this JSON data, do
//
//     final practiceVocabularyModel = practiceVocabularyModelFromJson(jsonString);

import 'dart:convert';

PracticeVocabularyModel practiceVocabularyModelFromJson(String str) =>
    PracticeVocabularyModel.fromJson(json.decode(str));

String practiceVocabularyModelToJson(PracticeVocabularyModel data) =>
    json.encode(data.toJson());

class PracticeVocabularyModel {
  bool ok;
  Meta meta;
  Data data;

  PracticeVocabularyModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory PracticeVocabularyModel.fromJson(Map<String, dynamic> json) =>
      PracticeVocabularyModel(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data.toJson(),
      };
}

class Data {
  Word correctWord;
  Word wrongWord;

  Data({
    required this.correctWord,
    required this.wrongWord,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        correctWord: Word.fromJson(json["correctWord"]),
        wrongWord: Word.fromJson(json["wrongWord"]),
      );

  Map<String, dynamic> toJson() => {
        "correctWord": correctWord.toJson(),
        "wrongWord": wrongWord.toJson(),
      };
}

class Word {
  String id;
  String word;
  String translation;
  String thumbnail;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic disabledAt;
  String courseId;

  Word({
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

  factory Word.fromJson(Map<String, dynamic> json) => Word(
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
