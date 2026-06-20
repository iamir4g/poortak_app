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
  String? message;
  Data data;

  AuthRequestOtpModel({
    required this.ok,
    this.message,
    required this.data,
  });

  factory AuthRequestOtpModel.fromJson(Map<String, dynamic> json) =>
      AuthRequestOtpModel(
        ok: json["ok"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "message": message,
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
  int otpLength;

  Result({
    required this.otpLength,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        otpLength: json["otpLength"] ?? 4,
      );

  Map<String, dynamic> toJson() => {
        "otpLength": otpLength,
      };
}
