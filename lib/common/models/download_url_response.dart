// To parse this JSON data, do
//
//     final getDownloadUrl = getDownloadUrlFromJson(jsonString);

import 'dart:convert';

GetDownloadUrl getDownloadUrlFromJson(String str) =>
    GetDownloadUrl.fromJson(json.decode(str));

String getDownloadUrlToJson(GetDownloadUrl data) => json.encode(data.toJson());

class GetDownloadUrl {
  bool ok;
  Meta meta;
  String data;

  GetDownloadUrl({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory GetDownloadUrl.fromJson(Map<String, dynamic> json) => GetDownloadUrl(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
