// To parse this JSON data, do
//
//     final match = matchFromJson(jsonString);

import 'dart:convert';

Match matchFromJson(String str) => Match.fromJson(json.decode(str));

String matchToJson(Match data) => json.encode(data.toJson());

class Match {
  bool ok;
  Meta meta;
  Data data;

  Match({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory Match.fromJson(Map<String, dynamic> json) => Match(
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
  MatchClass match;
  dynamic answer;

  Data({
    required this.match,
    required this.answer,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        match: MatchClass.fromJson(json["match"]),
        answer: json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "match": match.toJson(),
        "answer": answer,
      };
}

class MatchClass {
  String id;
  String name;
  String question;
  bool isCaseSensitive;
  DateTime startsAt;
  DateTime endsAt;
  DateTime createdAt;
  DateTime updatedAt;

  MatchClass({
    required this.id,
    required this.name,
    required this.question,
    required this.isCaseSensitive,
    required this.startsAt,
    required this.endsAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchClass.fromJson(Map<String, dynamic> json) => MatchClass(
        id: json["id"],
        name: json["name"],
        question: json["question"],
        isCaseSensitive: json["isCaseSensitive"],
        startsAt: DateTime.parse(json["startsAt"]),
        endsAt: DateTime.parse(json["endsAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "question": question,
        "isCaseSensitive": isCaseSensitive,
        "startsAt": startsAt.toIso8601String(),
        "endsAt": endsAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
