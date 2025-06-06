// To parse this JSON data, do
//
//     final authRequestOtpModel = authRequestOtpModelFromJson(jsonString);

import 'dart:convert';

AuthRequestOtpModel authRequestOtpModelFromJson(String str) =>
    AuthRequestOtpModel.fromJson(json.decode(str));

String authRequestOtpModelToJson(AuthRequestOtpModel data) =>
    json.encode(data.toJson());

class AuthRequestOtpModel {
  bool ok;
  Data data;

  AuthRequestOtpModel({
    required this.ok,
    required this.data,
  });

  factory AuthRequestOtpModel.fromJson(Map<String, dynamic> json) =>
      AuthRequestOtpModel(
        ok: json["ok"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "data": data.toJson(),
      };
}

class Data {
  Result result;

  Data({
    required this.result,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result.toJson(),
      };
}

class Result {
  String otp;

  Result({
    required this.otp,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        otp: json["otp"],
      );

  Map<String, dynamic> toJson() => {
        "otp": otp,
      };
}
