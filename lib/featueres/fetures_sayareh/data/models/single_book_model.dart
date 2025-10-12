// To parse this JSON data, do
//
//     final SingleBookModel = SingleBookModelFromJson(jsonString);

import 'dart:convert';

SingleBookModel SingleBookModelFromJson(String str) =>
    SingleBookModel.fromJson(json.decode(str));

String SingleBookModelToJson(SingleBookModel data) =>
    json.encode(data.toJson());

class SingleBookModel {
  bool ok;
  Meta meta;
  SingleBookData data;

  SingleBookModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory SingleBookModel.fromJson(Map<String, dynamic> json) =>
      SingleBookModel(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: SingleBookData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data.toJson(),
      };
}

class SingleBookData {
  String id;
  String title;
  String? description;
  int order;
  String thumbnail;
  String price;
  String? author;
  String? publisher;
  int pageCount;
  String publishDate;
  String? file;
  String? trialFile;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? publishedAt;
  bool? purchased;

  SingleBookData({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    required this.thumbnail,
    required this.price,
    this.author,
    this.publisher,
    required this.pageCount,
    required this.publishDate,
    this.file,
    this.trialFile,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.purchased,
  });

  factory SingleBookData.fromJson(Map<String, dynamic> json) => SingleBookData(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        description: json["description"],
        order: json["order"] ?? 0,
        thumbnail: json["thumbnail"] ?? "",
        price: json["price"] ?? "0",
        author: json["author"],
        publisher: json["publisher"],
        pageCount: json["pageCount"] ?? 0,
        publishDate: json["publishDate"] ?? "",
        file: json["file"],
        trialFile: json["trialFile"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : DateTime.now(),
        publishedAt: json["publishedAt"] == null
            ? null
            : DateTime.parse(json["publishedAt"]),
        purchased: json["purchased"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "order": order,
        "thumbnail": thumbnail,
        "price": price,
        "author": author,
        "publisher": publisher,
        "pageCount": pageCount,
        "publishDate": publishDate,
        "file": file,
        "trialFile": trialFile,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "publishedAt": publishedAt?.toIso8601String(),
        "purchased": purchased,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
