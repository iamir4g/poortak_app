// To parse this JSON data, do
//
//     final submitReviewWord = submitReviewWordFromJson(jsonString);

import 'dart:convert';

SubmitReviewWord submitReviewWordFromJson(String str) =>
    SubmitReviewWord.fromJson(json.decode(str));

String submitReviewWordToJson(SubmitReviewWord data) =>
    json.encode(data.toJson());

class SubmitReviewWord {
  bool ok;
  Meta meta;
  Data data;

  SubmitReviewWord({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory SubmitReviewWord.fromJson(Map<String, dynamic> json) =>
      SubmitReviewWord(
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
  String id;
  String userId;
  String word;
  String translation;
  int boxLevel;
  DateTime nextReview;
  DateTime lastReviewed;
  DateTime createdAt;
  DateTime updatedAt;

  Data({
    required this.id,
    required this.userId,
    required this.word,
    required this.translation,
    required this.boxLevel,
    required this.nextReview,
    required this.lastReviewed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        userId: json["userId"],
        word: json["word"],
        translation: json["translation"],
        boxLevel: json["boxLevel"],
        nextReview: DateTime.parse(json["nextReview"]),
        lastReviewed: DateTime.parse(json["lastReviewed"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "word": word,
        "translation": translation,
        "boxLevel": boxLevel,
        "nextReview": nextReview.toIso8601String(),
        "lastReviewed": lastReviewed.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
