// To parse this JSON data, do
//
//     final sayarehHomeModel = sayarehHomeModelFromJson(jsonString);

import 'dart:convert';

SayarehHomeModel sayarehHomeModelFromJson(String str) =>
    SayarehHomeModel.fromJson(json.decode(str));

String sayarehHomeModelToJson(SayarehHomeModel data) =>
    json.encode(data.toJson());

class SayarehHomeModel {
  bool ok;
  Meta meta;
  List<Lesson> data;

  SayarehHomeModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory SayarehHomeModel.fromJson(Map<String, dynamic> json) =>
      SayarehHomeModel(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: List<Lesson>.from(json["data"].map((x) => Lesson.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Lesson {
  String id;
  String name;
  String description;
  String thumbnail;
  String price;
  String video;
  String trailerVideo;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime publishedAt;

  Lesson({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
    required this.price,
    required this.video,
    required this.trailerVideo,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.publishedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        thumbnail: json["thumbnail"],
        price: json["price"],
        video: json["video"],
        trailerVideo: json["trailerVideo"],
        order: json["order"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        publishedAt: DateTime.parse(json["publishedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "thumbnail": thumbnail,
        "price": price,
        "video": video,
        "trailerVideo": trailerVideo,
        "order": order,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "publishedAt": publishedAt.toIso8601String(),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
