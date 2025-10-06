class PrizeHistoryModel {
  final String id;
  final String title;
  final String points;
  final String date;
  final bool isCompleted;

  PrizeHistoryModel({
    required this.id,
    required this.title,
    required this.points,
    required this.date,
    this.isCompleted = true,
  });

  factory PrizeHistoryModel.fromJson(Map<String, dynamic> json) {
    return PrizeHistoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      points: json['points'] ?? '',
      date: json['date'] ?? '',
      isCompleted: json['isCompleted'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'points': points,
      'date': date,
      'isCompleted': isCompleted,
    };
  }
}

class PrizeHistoryGroup {
  final String date;
  final List<PrizeHistoryModel> items;

  PrizeHistoryGroup({
    required this.date,
    required this.items,
  });
}
