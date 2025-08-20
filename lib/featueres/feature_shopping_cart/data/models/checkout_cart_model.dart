// To parse this JSON data, do
//
//     final checkoutCartModel = checkoutCartModelFromJson(jsonString);

import 'dart:convert';

CheckoutCartModel checkoutCartModelFromJson(String str) =>
    CheckoutCartModel.fromJson(json.decode(str));

String checkoutCartModelToJson(CheckoutCartModel data) =>
    json.encode(data.toJson());

class CheckoutCartModel {
  bool ok;
  Meta meta;
  Data? data;

  CheckoutCartModel({
    required this.ok,
    required this.meta,
    this.data,
  });

  factory CheckoutCartModel.fromJson(Map<String, dynamic> json) =>
      CheckoutCartModel(
        ok: json["ok"],
        meta: Meta.fromJson(json["meta"]),
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data?.toJson(),
      };
}

class Data {
  String url;

  Data({
    required this.url,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
