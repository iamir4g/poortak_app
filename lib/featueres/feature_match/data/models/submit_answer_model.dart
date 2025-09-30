// To parse this JSON data, do
//
//     final responseSubmitAnswer = responseSubmitAnswerFromJson(jsonString);

import 'dart:convert';

ResponseSubmitAnswer responseSubmitAnswerFromJson(String str) =>
    ResponseSubmitAnswer.fromJson(json.decode(str));

String responseSubmitAnswerToJson(ResponseSubmitAnswer data) =>
    json.encode(data.toJson());

class ResponseSubmitAnswer {
  bool ok;
  Meta meta;
  Data data;

  ResponseSubmitAnswer({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory ResponseSubmitAnswer.fromJson(Map<String, dynamic> json) =>
      ResponseSubmitAnswer(
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
  String matchId;
  String userId;
  String answer;
  bool isCorrect;
  DateTime submittedAt;
  DateTime createdAt;
  DateTime updatedAt;

  Data({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.answer,
    required this.isCorrect,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        matchId: json["matchId"],
        userId: json["userId"],
        answer: json["answer"],
        isCorrect: json["isCorrect"],
        submittedAt: DateTime.parse(json["submittedAt"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "matchId": matchId,
        "userId": userId,
        "answer": answer,
        "isCorrect": isCorrect,
        "submittedAt": submittedAt.toIso8601String(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
