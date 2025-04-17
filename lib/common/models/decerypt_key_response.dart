// To parse this JSON data, do
//
//     final getDeceryptKey = getDeceryptKeyFromJson(jsonString);

import 'dart:convert';

GetDeceryptKey getDeceryptKeyFromJson(String str) =>
    GetDeceryptKey.fromJson(json.decode(str));

String getDeceryptKeyToJson(GetDeceryptKey data) => json.encode(data.toJson());

class GetDeceryptKey {
  bool ok;
  Meta meta;
  Data data;

  GetDeceryptKey({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory GetDeceryptKey.fromJson(Map<String, dynamic> json) => GetDeceryptKey(
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
  String key;
  String fileId;
  DateTime createdAt;

  Data({
    required this.id,
    required this.key,
    required this.fileId,
    required this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        key: json["key"],
        fileId: json["fileId"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "fileId": fileId,
        "createdAt": createdAt.toIso8601String(),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
