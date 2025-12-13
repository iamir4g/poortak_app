class UserPointsTotalModel {
  final bool ok;
  final dynamic meta;
  final UserPointsTotalData data;

  UserPointsTotalModel({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory UserPointsTotalModel.fromJson(Map<String, dynamic> json) {
    return UserPointsTotalModel(
      ok: json['ok'] ?? false,
      meta: json['meta'] ?? 0,
      data: UserPointsTotalData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'meta': meta,
      'data': data.toJson(),
    };
  }
}

class UserPointsTotalData {
  final int remaining; // موجودی امتیاز قابل برداشت
  final int added; // مجموع امتیازهایی که کاربر تا الان کسب کرده
  final int? deducted; // مجموع امتیازهایی که کاربر تا الان مصرف کرده

  UserPointsTotalData({
    required this.remaining,
    required this.added,
    this.deducted,
  });

  factory UserPointsTotalData.fromJson(Map<String, dynamic> json) {
    return UserPointsTotalData(
      remaining: json['remaining'] ?? 0,
      added: json['added'] ?? 0,
      deducted: json['deducted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remaining': remaining,
      'added': added,
      'deducted': deducted,
    };
  }
}

