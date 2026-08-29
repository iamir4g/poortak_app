// To parse this JSON data, do
//
//     final iknowAccess = iknowAccessFromJson(jsonString);

import 'dart:convert';

IknowAccess iknowAccessFromJson(String str) =>
    IknowAccess.fromJson(json.decode(str));

String iknowAccessToJson(IknowAccess data) => json.encode(data.toJson());

class IknowAccess {
  bool ok;
  Meta meta;
  AccessData data;

  IknowAccess({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory IknowAccess.fromJson(Map<String, dynamic> json) => IknowAccess(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: AccessData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data.toJson(),
      };
}

class AccessData {
  List<String> courses;
  List<String> books;

  AccessData({
    required this.courses,
    required this.books,
  });

  factory AccessData.fromJson(Map<String, dynamic> json) => AccessData(
        courses: List<String>.from(json["courses"].map((x) => x)),
        books: List<String>.from(json["books"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "courses": List<dynamic>.from(courses.map((x) => x)),
        "books": List<dynamic>.from(books.map((x) => x)),
      };

  bool hasCourseAccess(String courseId) {
    return courses.contains(courseId);
  }

  bool hasBookAccess(String bookId) {
    return books.contains(bookId);
  }
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
