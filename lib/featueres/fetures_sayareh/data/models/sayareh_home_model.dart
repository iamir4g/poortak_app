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
  Data data;

  SayarehHomeModel({
    required this.ok,
    required this.data,
  });

  factory SayarehHomeModel.fromJson(Map<String, dynamic> json) =>
      SayarehHomeModel(
        ok: json["ok"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "data": data.toJson(),
      };
}

class Data {
  List<Sayareh> sayareh;

  Data({
    required this.sayareh,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        sayareh:
            List<Sayareh>.from(json["sayareh"].map((x) => Sayareh.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sayareh": List<dynamic>.from(sayareh.map((x) => x.toJson())),
      };
}

class Sayareh {
  String title;
  String description;
  String image;
  bool isLock;

  Sayareh({
    required this.title,
    required this.description,
    required this.image,
    required this.isLock,
  });

  factory Sayareh.fromJson(Map<String, dynamic> json) => Sayareh(
        title: json["title"],
        description: json["description"],
        image: json["image"],
        isLock: json["isLock"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "image": image,
        "isLock": isLock,
      };
}
