class PrizeHistoryModel {
  final String id;
  final int amount;
  final int remainingAmount;
  final String description;
  final String type;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrizeHistoryModel({
    required this.id,
    required this.amount,
    required this.remainingAmount,
    required this.description,
    required this.type,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrizeHistoryModel.fromJson(Map<String, dynamic> json) {
    return PrizeHistoryModel(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      remainingAmount: json['remainingAmount'] ?? 0,
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      userId: json['userId'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'remainingAmount': remainingAmount,
      'description': description,
      'type': type,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get points display text
  String get pointsDisplay => '$amount سکه';
}

class PrizeHistoryGroup {
  final String date;
  final List<PrizeHistoryModel> items;

  PrizeHistoryGroup({
    required this.date,
    required this.items,
  });
}

class PrizeHistoryResponse {
  final bool ok;
  final Map<String, dynamic> meta;
  final List<PrizeHistoryModel> data;

  PrizeHistoryResponse({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory PrizeHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PrizeHistoryResponse(
      ok: json['ok'] ?? false,
      meta: json['meta'] ?? {},
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => PrizeHistoryModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'meta': meta,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  // Helper method to calculate total amount
  int get totalAmount {
    return data.fold(0, (sum, item) => sum + item.amount);
  }
}
