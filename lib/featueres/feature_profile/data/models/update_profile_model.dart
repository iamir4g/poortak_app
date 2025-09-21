// To parse this JSON data, do
//
//     final updateProfileModel = updateProfileModelFromJson(jsonString);

import 'dart:convert';

UpdateProfileModel updateProfileModelFromJson(String str) =>
    UpdateProfileModel.fromJson(json.decode(str));

String updateProfileModelToJson(UpdateProfileModel data) =>
    json.encode(data.toJson());

class UpdateProfileModel {
  bool ok;
  Meta meta;
  Data data;

  UpdateProfileModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) =>
      UpdateProfileModel(
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
  String id;
  String? avatar;
  String email;
  String firstName;
  String? lastName;
  String phone;
  String? phoneVerifiedAt;
  String? verifyCode;
  String? ageGroup;
  String? nationalCode;
  String? province;
  String? city;
  String? address;
  String? postalCode;
  DateTime? birthdate;
  int rate;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? disabledAt;

  Data({
    required this.id,
    this.avatar,
    required this.email,
    required this.firstName,
    this.lastName,
    required this.phone,
    this.phoneVerifiedAt,
    this.verifyCode,
    this.ageGroup,
    this.nationalCode,
    this.province,
    this.city,
    this.address,
    this.postalCode,
    this.birthdate,
    required this.rate,
    required this.createdAt,
    required this.updatedAt,
    this.disabledAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        avatar: json["avatar"],
        email: json["email"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        phone: json["phone"],
        phoneVerifiedAt: json["phoneVerifiedAt"],
        verifyCode: json["verifyCode"],
        ageGroup: json["ageGroup"],
        nationalCode: json["nationalCode"],
        province: json["province"],
        city: json["city"],
        address: json["address"],
        postalCode: json["postalCode"],
        birthdate: json["birthdate"],
        rate: json["rate"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        disabledAt: json["disabledAt"] != null
            ? DateTime.parse(json["disabledAt"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "avatar": avatar,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "phoneVerifiedAt": phoneVerifiedAt,
        "verifyCode": verifyCode,
        "ageGroup": ageGroup,
        "nationalCode": nationalCode,
        "province": province,
        "city": city,
        "address": address,
        "postalCode": postalCode,
        "birthdate": birthdate,
        "rate": rate,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "disabledAt": disabledAt,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
