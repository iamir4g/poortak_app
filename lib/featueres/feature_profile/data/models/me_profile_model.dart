// To parse this JSON data, do
//
//     final meProfile = meProfileFromJson(jsonString);

import 'dart:convert';

MeProfileModel meProfileFromJson(String str) =>
    MeProfileModel.fromJson(json.decode(str));

String meProfileToJson(MeProfileModel data) => json.encode(data.toJson());

class MeProfileModel {
  bool ok;
  Data data;

  MeProfileModel({
    required this.ok,
    required this.data,
  });

  factory MeProfileModel.fromJson(Map<String, dynamic> json) => MeProfileModel(
        ok: json["ok"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "data": data.toJson(),
      };
}

class Data {
  String id;
  String? avatar;
  String email;
  String? firstName;
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
  String? birthdate;
  int rate;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? disabledAt;
  List<Role> roles;

  Data({
    required this.id,
    this.avatar,
    required this.email,
    this.firstName,
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
    required this.roles,
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
        disabledAt: json["disabledAt"],
        roles: List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
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
        "roles": List<dynamic>.from(roles.map((x) => x.toJson())),
      };
}

class Role {
  String id;
  String key;
  String title;
  DateTime createdAt;
  List<Permission> permissions;

  Role({
    required this.id,
    required this.key,
    required this.title,
    required this.createdAt,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        key: json["key"],
        title: json["title"],
        createdAt: DateTime.parse(json["createdAt"]),
        permissions: List<Permission>.from(
            json["permissions"].map((x) => Permission.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "title": title,
        "createdAt": createdAt.toIso8601String(),
        "permissions": List<dynamic>.from(permissions.map((x) => x.toJson())),
      };
}

class Permission {
  String id;
  String action;
  String subject;
  DateTime createdAt;

  Permission({
    required this.id,
    required this.action,
    required this.subject,
    required this.createdAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) => Permission(
        id: json["id"],
        action: json["action"],
        subject: json["subject"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "action": action,
        "subject": subject,
        "createdAt": createdAt.toIso8601String(),
      };
}
