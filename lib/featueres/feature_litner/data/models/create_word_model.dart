// To parse this JSON data, do
//
//     final createWord = createWordFromJson(jsonString);

import 'dart:convert';

CreateWord createWordFromJson(String str) =>
    CreateWord.fromJson(json.decode(str));

String createWordToJson(CreateWord data) => json.encode(data.toJson());

class CreateWord {
  bool ok;
  Meta meta;
  Data data;

  CreateWord({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory CreateWord.fromJson(Map<String, dynamic> json) => CreateWord(
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
  DateTime? lastReviewed;
  DateTime createdAt;
  DateTime updatedAt;

  Data({
    required this.id,
    required this.userId,
    required this.word,
    required this.translation,
    required this.boxLevel,
    required this.nextReview,
    this.lastReviewed,
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
        lastReviewed: json["lastReviewed"] != null
            ? DateTime.parse(json["lastReviewed"])
            : null,
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
        "lastReviewed": lastReviewed?.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
