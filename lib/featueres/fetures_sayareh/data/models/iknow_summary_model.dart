import 'dart:convert';

import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';

IKnowSummaryModel iKnowSummaryModelFromJson(String str) =>
    IKnowSummaryModel.fromJson(json.decode(str));

String iKnowSummaryModelToJson(IKnowSummaryModel data) =>
    json.encode(data.toJson());

class IKnowSummaryModel {
  bool ok;
  Meta meta;
  IKnowSummaryData data;

  IKnowSummaryModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory IKnowSummaryModel.fromJson(Map<String, dynamic> json) =>
      IKnowSummaryModel(
        ok: json["ok"] ?? false,
        meta: Meta.fromJson(json["meta"] ?? {}),
        data: IKnowSummaryData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data.toJson(),
      };
}

class IKnowSummaryData {
  List<IKnowSummaryCourse> courses;
  List<IKnowSummaryBook> books;
  IKnowSummarySettings settings;

  IKnowSummaryData({
    required this.courses,
    required this.books,
    required this.settings,
  });

  factory IKnowSummaryData.fromJson(Map<String, dynamic> json) =>
      IKnowSummaryData(
        courses: json["courses"] != null
            ? List<IKnowSummaryCourse>.from(
                json["courses"].map((x) => IKnowSummaryCourse.fromJson(x)),
              )
            : [],
        books: json["books"] != null
            ? List<IKnowSummaryBook>.from(
                json["books"].map((x) => IKnowSummaryBook.fromJson(x)),
              )
            : [],
        settings: IKnowSummarySettings.fromJson(json["settings"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "courses": List<dynamic>.from(courses.map((x) => x.toJson())),
        "books": List<dynamic>.from(books.map((x) => x.toJson())),
        "settings": settings.toJson(),
      };
}

class IKnowSummaryCourse {
  String id;
  String name;
  String description;
  String price;
  int order;

  IKnowSummaryCourse({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.order,
  });

  factory IKnowSummaryCourse.fromJson(Map<String, dynamic> json) =>
      IKnowSummaryCourse(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        description: json["description"] ?? "",
        price: json["price"] ?? "0",
        order: json["order"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "order": order,
      };
}

class IKnowSummaryBook {
  String id;
  String title;
  String description;
  int order;
  String price;

  IKnowSummaryBook({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.price,
  });

  factory IKnowSummaryBook.fromJson(Map<String, dynamic> json) =>
      IKnowSummaryBook(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        order: json["order"] ?? 0,
        price: json["price"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "order": order,
        "price": price,
      };
}

class IKnowSummarySettings {
  String id;
  String price;
  String discountType;
  String discountAmount;

  IKnowSummarySettings({
    required this.id,
    required this.price,
    required this.discountType,
    required this.discountAmount,
  });

  factory IKnowSummarySettings.fromJson(Map<String, dynamic> json) =>
      IKnowSummarySettings(
        id: json["id"] ?? "",
        price: json["price"] ?? "0",
        discountType: json["discountType"] ?? "",
        discountAmount: json["discountAmount"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "price": price,
        "discountType": discountType,
        "discountAmount": discountAmount,
      };
}
