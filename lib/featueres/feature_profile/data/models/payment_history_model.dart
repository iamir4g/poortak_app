// To parse this JSON data, do
//
//     final paymentHistoryList = paymentHistoryListFromJson(jsonString);

import 'dart:convert';

PaymentHistoryList paymentHistoryListFromJson(String str) =>
    PaymentHistoryList.fromJson(json.decode(str));

String paymentHistoryListToJson(PaymentHistoryList data) =>
    json.encode(data.toJson());

class PaymentHistoryList {
  bool? ok;
  Meta? meta;
  List<Datum>? data;

  PaymentHistoryList({
    this.ok,
    this.meta,
    this.data,
  });

  factory PaymentHistoryList.fromJson(Map<String, dynamic> json) =>
      PaymentHistoryList(
        ok: json["ok"],
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta?.toJson(),
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  String? userId;
  String? source;
  String? status;
  String? trackingCode;
  dynamic buyerEmail;
  String? buyerMobile;
  dynamic discountCode;
  dynamic discountAmount;
  dynamic discountType;
  String? subTotal;
  String? grandTotal;
  dynamic referenceId;
  dynamic cardPan;
  dynamic authority;
  String? description;
  dynamic internalNote;
  dynamic paidAt;
  DateTime? expiresAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Item>? items;

  Datum({
    this.id,
    this.userId,
    this.source,
    this.status,
    this.trackingCode,
    this.buyerEmail,
    this.buyerMobile,
    this.discountCode,
    this.discountAmount,
    this.discountType,
    this.subTotal,
    this.grandTotal,
    this.referenceId,
    this.cardPan,
    this.authority,
    this.description,
    this.internalNote,
    this.paidAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["userId"],
        source: json["source"],
        status: json["status"],
        trackingCode: json["trackingCode"],
        buyerEmail: json["buyerEmail"],
        buyerMobile: json["buyerMobile"],
        discountCode: json["discountCode"],
        discountAmount: json["discountAmount"],
        discountType: json["discountType"],
        subTotal: json["subTotal"],
        grandTotal: json["grandTotal"],
        referenceId: json["referenceId"],
        cardPan: json["cardPan"],
        authority: json["authority"],
        description: json["description"],
        internalNote: json["internalNote"],
        paidAt: json["paidAt"],
        expiresAt: json["expiresAt"] == null
            ? null
            : DateTime.parse(json["expiresAt"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        items: json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "source": source,
        "status": status,
        "trackingCode": trackingCode,
        "buyerEmail": buyerEmail,
        "buyerMobile": buyerMobile,
        "discountCode": discountCode,
        "discountAmount": discountAmount,
        "discountType": discountType,
        "subTotal": subTotal,
        "grandTotal": grandTotal,
        "referenceId": referenceId,
        "cardPan": cardPan,
        "authority": authority,
        "description": description,
        "internalNote": internalNote,
        "paidAt": paidAt,
        "expiresAt": expiresAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class Item {
  String? id;
  String? paymentId;
  String? itemType;
  String? itemId;
  dynamic description;
  dynamic discountCode;
  dynamic discountAmount;
  dynamic discountType;
  int? quantity;
  String? price;
  DateTime? createdAt;
  DateTime? updatedAt;

  Item({
    this.id,
    this.paymentId,
    this.itemType,
    this.itemId,
    this.description,
    this.discountCode,
    this.discountAmount,
    this.discountType,
    this.quantity,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        paymentId: json["paymentId"],
        itemType: json["itemType"],
        itemId: json["itemId"],
        description: json["description"],
        discountCode: json["discountCode"],
        discountAmount: json["discountAmount"],
        discountType: json["discountType"],
        quantity: json["quantity"],
        price: json["price"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "paymentId": paymentId,
        "itemType": itemType,
        "itemId": itemId,
        "description": description,
        "discountCode": discountCode,
        "discountAmount": discountAmount,
        "discountType": discountType,
        "quantity": quantity,
        "price": price,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class Meta {
  int? count;

  Meta({
    this.count,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
      };
}

// // To parse this JSON data, do
// //
// //     final paymentHistoryList = paymentHistoryListFromJson(jsonString);

// import 'dart:convert';
// import 'package:poortak/common/models/cart_enum.dart';

// PaymentHistoryList paymentHistoryListFromJson(String str) =>
//     PaymentHistoryList.fromJson(json.decode(str));

// String paymentHistoryListToJson(PaymentHistoryList data) =>
//     json.encode(data.toJson());

// class PaymentHistoryList {
//   bool ok;
//   Meta meta;
//   List<Datum> data;

//   PaymentHistoryList({
//     required this.ok,
//     required this.meta,
//     required this.data,
//   });

//   factory PaymentHistoryList.fromJson(Map<String, dynamic> json) =>
//       PaymentHistoryList(
//         ok: json["ok"],
//         meta: Meta.fromJson(json["meta"]),
//         data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "ok": ok,
//         "meta": meta.toJson(),
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//       };
// }

// class Datum {
//   String id;
//   String userId;
//   Source source;
//   Status status;
//   String trackingCode;
//   BuyerEmail? buyerEmail;
//   String buyerMobile;
//   dynamic discountCode;
//   String? discountAmount;
//   dynamic discountType;
//   String subTotal;
//   String grandTotal;
//   dynamic referenceId;
//   dynamic cardPan;
//   String? authority;
//   String description;
//   dynamic internalNote;
//   dynamic paidAt;
//   DateTime expiresAt;
//   DateTime createdAt;
//   DateTime updatedAt;
//   List<Item> items;

//   Datum({
//     required this.id,
//     required this.userId,
//     required this.source,
//     required this.status,
//     required this.trackingCode,
//     this.buyerEmail,
//     required this.buyerMobile,
//     required this.discountCode,
//     this.discountAmount,
//     required this.discountType,
//     required this.subTotal,
//     required this.grandTotal,
//     required this.referenceId,
//     required this.cardPan,
//     required this.authority,
//     required this.description,
//     required this.internalNote,
//     required this.paidAt,
//     required this.expiresAt,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.items,
//   });

//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//         id: json["id"],
//         userId: json["userId"],
//         source: sourceValues.map[json["source"]]!,
//         status: statusValues.map[json["status"]]!,
//         trackingCode: json["trackingCode"],
//         buyerEmail: json["buyerEmail"] != null
//             ? buyerEmailValues.map[json["buyerEmail"]]
//             : null,
//         buyerMobile: json["buyerMobile"],
//         discountCode: json["discountCode"],
//         discountAmount: json["discountAmount"],
//         discountType: json["discountType"],
//         subTotal: json["subTotal"],
//         grandTotal: json["grandTotal"],
//         referenceId: json["referenceId"],
//         cardPan: json["cardPan"],
//         authority: json["authority"],
//         description: json["description"],
//         internalNote: json["internalNote"],
//         paidAt: json["paidAt"],
//         expiresAt: DateTime.parse(json["expiresAt"]),
//         createdAt: DateTime.parse(json["createdAt"]),
//         updatedAt: DateTime.parse(json["updatedAt"]),
//         items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "userId": userId,
//         "source": sourceValues.reverse[source],
//         "status": statusValues.reverse[status],
//         "trackingCode": trackingCode,
//         "buyerEmail":
//             buyerEmail != null ? buyerEmailValues.reverse[buyerEmail] : null,
//         "buyerMobile": buyerMobile,
//         "discountCode": discountCode,
//         "discountAmount": discountAmount,
//         "discountType": discountType,
//         "subTotal": subTotal,
//         "grandTotal": grandTotal,
//         "referenceId": referenceId,
//         "cardPan": cardPan,
//         "authority": authority,
//         "description": description,
//         "internalNote": internalNote,
//         "paidAt": paidAt,
//         "expiresAt": expiresAt.toIso8601String(),
//         "createdAt": createdAt.toIso8601String(),
//         "updatedAt": updatedAt.toIso8601String(),
//         "items": List<dynamic>.from(items.map((x) => x.toJson())),
//       };
// }

// enum BuyerEmail { BEYRAMIBAHAREH_GMAIL_COM }

// final buyerEmailValues = EnumValues(
//     {"beyramibahareh@gmail.com": BuyerEmail.BEYRAMIBAHAREH_GMAIL_COM});

// class Item {
//   String id;
//   String paymentId;
//   CartType itemType;
//   String itemId;
//   Description? description;
//   dynamic discountCode;
//   String? discountAmount;
//   DiscountType? discountType;
//   int quantity;
//   String price;
//   DateTime createdAt;
//   DateTime updatedAt;

//   Item({
//     required this.id,
//     required this.paymentId,
//     required this.itemType,
//     required this.itemId,
//     this.description,
//     required this.discountCode,
//     this.discountAmount,
//     this.discountType,
//     required this.quantity,
//     required this.price,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Item.fromJson(Map<String, dynamic> json) => Item(
//         id: json["id"],
//         paymentId: json["paymentId"],
//         itemType: itemTypeValues.map[json["itemType"]]!,
//         itemId: json["itemId"],
//         description: json["description"] != null
//             ? descriptionValues.map[json["description"]]
//             : null,
//         discountCode: json["discountCode"],
//         discountAmount: json["discountAmount"],
//         discountType: json["discountType"] != null
//             ? discountTypeValues.map[json["discountType"]]
//             : null,
//         quantity: json["quantity"],
//         price: json["price"],
//         createdAt: DateTime.parse(json["createdAt"]),
//         updatedAt: DateTime.parse(json["updatedAt"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "paymentId": paymentId,
//         "itemType": itemTypeValues.reverse[itemType],
//         "itemId": itemId,
//         "description":
//             description != null ? descriptionValues.reverse[description] : null,
//         "discountCode": discountCode,
//         "discountAmount": discountAmount,
//         "discountType": discountType != null
//             ? discountTypeValues.reverse[discountType]
//             : null,
//         "quantity": quantity,
//         "price": price,
//         "createdAt": createdAt.toIso8601String(),
//         "updatedAt": updatedAt.toIso8601String(),
//       };
// }

// enum Description { EMPTY, PURCHASING_I_KNOW_COLLECTION }

// final descriptionValues = EnumValues({
//   "خرید مجموعه سیاره آی\u200cنو.": Description.EMPTY,
//   "Purchasing 'I Know' collection.": Description.PURCHASING_I_KNOW_COLLECTION
// });

// enum DiscountType { PERCENT }

// final discountTypeValues = EnumValues({"Percent": DiscountType.PERCENT});

// // enum ItemType {
// //     I_KNOW
// // }

// final itemTypeValues = EnumValues({
//   "IKnow": CartType.IKnow,
//   "IKnowBook": CartType.IKnowBook,
//   "IKnowCourse": CartType.IKnowCourse,
// });

// enum Source { IPG, CARD }

// final sourceValues = EnumValues({
//   "IPG": Source.IPG,
//   "Card": Source.CARD,
// });

// enum Status { PENDING, SUCCEEDED, FAILED, EXPIRED, REFUNDED }

// final statusValues = EnumValues({
//   "Pending": Status.PENDING,
//   "Succeeded": Status.SUCCEEDED,
//   "Failed": Status.FAILED,
//   "Expired": Status.EXPIRED,
//   "Refunded": Status.REFUNDED
// });

// class Meta {
//   int count;

//   Meta({
//     required this.count,
//   });

//   factory Meta.fromJson(Map<String, dynamic> json) => Meta(
//         count: json["count"],
//       );

//   Map<String, dynamic> toJson() => {
//         "count": count,
//       };
// }

// class EnumValues<T> {
//   Map<String, T> map;
//   late Map<T, String> reverseMap;

//   EnumValues(this.map);

//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }
