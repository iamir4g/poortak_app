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
  List<CartItem>? items;

  Cart({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        userId: json["userId"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        items: json["items"] != null
            ? List<CartItem>.from(
                json["items"].map((x) => CartItem.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "items": items != null
            ? List<dynamic>.from(items!.map((x) => x.toJson()))
            : [],
      };
}

class CartItem {
  String id;
  String cartId;
  String itemId;
  String type;
  int quantity;
  String price;
  DateTime createdAt;
  DateTime updatedAt;
  CartItemSource source;

  CartItem({
    required this.id,
    required this.cartId,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json["id"],
        cartId: json["cartId"],
        itemId: json["itemId"],
        type: json["type"],
        quantity: json["quantity"],
        price: json["price"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        source: CartItemSource.fromJson(json["source"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cartId": cartId,
        "itemId": itemId,
        "type": type,
        "quantity": quantity,
        "price": price,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "source": source.toJson(),
      };
}

class CartItemSource {
  String id;
  String price;
  String discountType;
  String discountAmount;

  CartItemSource({
    required this.id,
    required this.price,
    required this.discountType,
    required this.discountAmount,
  });

  factory CartItemSource.fromJson(Map<String, dynamic> json) => CartItemSource(
        id: json["id"],
        price: json["price"],
        discountType: json["discountType"],
        discountAmount: json["discountAmount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "price": price,
        "discountType": discountType,
        "discountAmount": discountAmount,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
