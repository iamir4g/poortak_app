// To parse this JSON data, do
//
//     final overviewLinter = overviewLinterFromJson(jsonString);

import 'dart:convert';

OverviewLinter overviewLinterFromJson(String str) =>
    OverviewLinter.fromJson(json.decode(str));

String overviewLinterToJson(OverviewLinter data) => json.encode(data.toJson());

class OverviewLinter {
  bool ok;
  Meta meta;
  Data data;

  OverviewLinter({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory OverviewLinter.fromJson(Map<String, dynamic> json) => OverviewLinter(
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
  int completedWordsCount;
  int inProgressWordsCount;
  int todayWordsCount;

  Data({
    required this.completedWordsCount,
    required this.inProgressWordsCount,
    required this.todayWordsCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        completedWordsCount: json["completedWordsCount"],
        inProgressWordsCount: json["inProgressWordsCount"],
        todayWordsCount: json["todayWordsCount"],
      );

  Map<String, dynamic> toJson() => {
        "completedWordsCount": completedWordsCount,
        "inProgressWordsCount": inProgressWordsCount,
        "todayWordsCount": todayWordsCount,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
