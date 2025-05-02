// To parse this JSON data, do
//
//     final conversationModel = conversationModelFromJson(jsonString);

import 'dart:convert';

ConversationModel conversationModelFromJson(String str) =>
    ConversationModel.fromJson(json.decode(str));

String conversationModelToJson(ConversationModel data) =>
    json.encode(data.toJson());

class ConversationModel {
  bool ok;
  Meta meta;
  List<Datum> data;

  ConversationModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
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
  String text;
  String translation;
  String voice;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic disabledAt;
  String courseId;

  Datum({
    required this.id,
    required this.text,
    required this.translation,
    required this.voice,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.disabledAt,
    required this.courseId,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        text: json["text"],
        translation: json["translation"],
        voice: json["voice"],
        order: json["order"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        disabledAt: json["disabledAt"],
        courseId: json["courseId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "translation": translation,
        "voice": voice,
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
