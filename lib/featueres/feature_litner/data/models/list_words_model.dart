// To parse this JSON data, do
//
//     final listWords = listWordsFromJson(jsonString);

import 'dart:convert';

ListWords listWordsFromJson(String str) => ListWords.fromJson(json.decode(str));

String listWordsToJson(ListWords data) => json.encode(data.toJson());

class ListWords {
  bool ok;
  Meta meta;
  List<Datum> data;

  ListWords({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory ListWords.fromJson(Map<String, dynamic> json) => ListWords(
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
  String userId;
  String word;
  String translation;
  int boxLevel;
  DateTime nextReview;
  DateTime? lastReviewed;
  DateTime createdAt;
  DateTime updatedAt;

  Datum({
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["userId"],
        word: json["word"],
        translation: json["translation"],
        boxLevel: json["boxLevel"],
        nextReview: DateTime.parse(json["nextReview"]),
        lastReviewed: json["lastReviewed"] == null
            ? null
            : DateTime.parse(json["lastReviewed"]),
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
  int count;

  Meta({
    required this.count,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
      };
}
