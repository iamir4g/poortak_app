// To parse this JSON data, do
//
//     final getCartModel = getCartModelFromJson(jsonString);

import 'dart:convert';

GetCartModel getCartModelFromJson(String str) =>
    GetCartModel.fromJson(json.decode(str));

String getCartModelToJson(GetCartModel data) => json.encode(data.toJson());

class GetCartModel {
  bool ok;
  Meta meta;
  Data data;

  GetCartModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory GetCartModel.fromJson(Map<String, dynamic> json) => GetCartModel(
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
  Cart cart;
  int subTotal;
  int grandTotal;

  Data({
    required this.cart,
    required this.subTotal,
    required this.grandTotal,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        cart: Cart.fromJson(json["cart"]),
        subTotal: json["subTotal"],
        grandTotal: json["grandTotal"],
      );

  Map<String, dynamic> toJson() => {
        "cart": cart.toJson(),
        "subTotal": subTotal,
        "grandTotal": grandTotal,
      };
}

class Cart {
  String id;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;
  List<dynamic> items;

  Cart({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        userId: json["userId"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        items: List<dynamic>.from(json["items"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "items": List<dynamic>.from(items.map((x) => x)),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
