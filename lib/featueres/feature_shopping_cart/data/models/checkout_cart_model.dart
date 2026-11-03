// To parse this JSON data, do
//
//     final checkoutCartModel = checkoutCartModelFromJson(jsonString);

import 'dart:convert';

import 'package:poortak/common/utils/money_utils.dart';

CheckoutCartModel checkoutCartModelFromJson(String str) =>
    CheckoutCartModel.fromJson(json.decode(str));

String checkoutCartModelToJson(CheckoutCartModel data) =>
    json.encode(data.toJson());

class CheckoutCartModel {
  bool ok;
  Meta meta;
  CheckoutData? data;

  CheckoutCartModel({
    required this.ok,
    required this.meta,
    this.data,
  });

  factory CheckoutCartModel.fromJson(Map<String, dynamic> json) =>
      CheckoutCartModel(
        ok: json["ok"] == true,
        meta: Meta.fromJson(
          json["meta"] is Map
              ? Map<String, dynamic>.from(json["meta"] as Map)
              : {},
        ),
        data: json["data"] is Map
            ? CheckoutData.fromJson(Map<String, dynamic>.from(json["data"] as Map))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data?.toJson(),
      };
}

class CheckoutData {
  final String? url;
  final String paymentId;
  final int amount;
  final bool isFree;

  const CheckoutData({
    this.url,
    required this.paymentId,
    required this.amount,
    required this.isFree,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    final rawUrl = json["url"]?.toString().trim();
    return CheckoutData(
      url: (rawUrl == null || rawUrl.isEmpty) ? null : rawUrl,
      paymentId: json["paymentId"]?.toString() ?? '',
      amount: MoneyUtils.parseRial(json["amount"]),
      isFree: json["isFree"] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        "url": url,
        "paymentId": paymentId,
        "amount": amount,
        "isFree": isFree,
      };

  bool get shouldOpenGateway =>
      !isFree && url != null && url!.isNotEmpty && amount > 0;
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
