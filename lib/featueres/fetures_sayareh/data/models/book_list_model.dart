// To parse this JSON data, do
//
//     final GetBookListModel = GetBookListModelFromJson(jsonString);

import 'dart:convert';

GetBookListModel GetBookListModelFromJson(String str) =>
    GetBookListModel.fromJson(json.decode(str));

String GetBookListModelToJson(GetBookListModel data) =>
    json.encode(data.toJson());

class GetBookListModel {
  bool ok;
  Meta meta;
  List<BookList>? data;

  GetBookListModel({
    required this.ok,
    required this.meta,
    this.data,
  });

  factory GetBookListModel.fromJson(Map<String, dynamic> json) =>
      GetBookListModel(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: json["data"] != null
            ? List<BookList>.from(json["data"].map((x) => BookList.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : null,
      };
}

class BookList {
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
  String file;
  String? trialFile;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? publishedAt;

  BookList({
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
    required this.file,
    this.trialFile,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory BookList.fromJson(Map<String, dynamic> json) => BookList(
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
        file: json["file"] ?? "",
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
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
