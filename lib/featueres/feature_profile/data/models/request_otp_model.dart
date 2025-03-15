// To parse this JSON data, do
//
//     final requestOtpModel = requestOtpModelFromJson(jsonString);

import 'dart:convert';

RequestOtpModel requestOtpModelFromJson(String str) =>
    RequestOtpModel.fromJson(json.decode(str));

String requestOtpModelToJson(RequestOtpModel data) =>
    json.encode(data.toJson());

class RequestOtpModel {
  bool ok;
  Data data;

  RequestOtpModel({
    required this.ok,
    required this.data,
  });

  factory RequestOtpModel.fromJson(Map<String, dynamic> json) =>
      RequestOtpModel(
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
