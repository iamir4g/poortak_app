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
  String? name;
  String? description;
  String? thumbnail;
  bool? isDemo;
  String price;
  String? video;
  String? trailerVideo;
  int? order;
  String? discountType;
  String? discountAmount;

  CartItemSource({
    required this.id,
    this.name,
    this.description,
    this.thumbnail,
    this.isDemo,
    required this.price,
    this.video,
    this.trailerVideo,
    this.order,
    this.discountType,
    this.discountAmount,
  });

  factory CartItemSource.fromJson(Map<String, dynamic> json) => CartItemSource(
        id: json["id"] ?? "",
        name: json["name"],
        description: json["description"],
        thumbnail: json["thumbnail"],
        isDemo: json["isDemo"],
        price: json["price"] ?? "0",
        video: json["video"],
        trailerVideo: json["trailerVideo"],
        order: json["order"],
        discountType: json["discountType"],
        discountAmount: json["discountAmount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (thumbnail != null) "thumbnail": thumbnail,
        if (isDemo != null) "isDemo": isDemo,
        "price": price,
        if (video != null) "video": video,
        if (trailerVideo != null) "trailerVideo": trailerVideo,
        if (order != null) "order": order,
        if (discountType != null) "discountType": discountType,
        if (discountAmount != null) "discountAmount": discountAmount,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
