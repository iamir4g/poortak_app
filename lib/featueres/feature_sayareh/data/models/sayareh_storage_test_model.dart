// To parse this JSON data, do
//
//     final sayarehStorageTest = sayarehStorageTestFromJson(jsonString);

import 'dart:convert';

SayarehStorageTest sayarehStorageTestFromJson(String str) =>
    SayarehStorageTest.fromJson(json.decode(str));

String sayarehStorageTestToJson(SayarehStorageTest data) =>
    json.encode(data.toJson());

class SayarehStorageTest {
  bool ok;
  Meta meta;
  List<StorageFile> data;

  SayarehStorageTest({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory SayarehStorageTest.fromJson(Map<String, dynamic> json) =>
      SayarehStorageTest(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: List<StorageFile>.from(
            json["data"].map((x) => StorageFile.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class StorageFile {
  String id;
  String name;
  String key;
  int size;
  String mimetype;
  bool isEncrypted;
  bool isPublic;
  DateTime createdAt;
  DateTime updatedAt;

  StorageFile({
    required this.id,
    required this.name,
    required this.key,
    required this.size,
    required this.mimetype,
    required this.isEncrypted,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StorageFile.fromJson(Map<String, dynamic> json) => StorageFile(
        id: json["id"],
        name: json["name"],
        key: json["key"],
        size: json["size"],
        mimetype: json["mimetype"],
        isEncrypted: json["isEncrypted"],
        isPublic: json["isPublic"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "key": key,
        "size": size,
        "mimetype": mimetype,
        "isEncrypted": isEncrypted,
        "isPublic": isPublic,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Meta {
  int count;

  Meta({
    required this.count,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
      };
}
