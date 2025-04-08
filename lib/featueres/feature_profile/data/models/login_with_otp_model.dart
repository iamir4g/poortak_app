// To parse this JSON data, do
//
//     final authLoginOtpModel = authLoginOtpModelFromJson(jsonString);

import 'dart:convert';

AuthLoginOtpModel authLoginOtpModelFromJson(String str) =>
    AuthLoginOtpModel.fromJson(json.decode(str));

String authLoginOtpModelToJson(AuthLoginOtpModel data) =>
    json.encode(data.toJson());

class AuthLoginOtpModel {
  bool ok;
  Data data;

  AuthLoginOtpModel({
    required this.ok,
    required this.data,
  });

  factory AuthLoginOtpModel.fromJson(Map<String, dynamic> json) =>
      AuthLoginOtpModel(
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
  String accessToken;
  String refreshToken;

  Result({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}
