class QuizProgressModel {
  final bool ok;
  final List<QuizProgressData> data;

  const QuizProgressModel({
    required this.ok,
    required this.data,
  });

  factory QuizProgressModel.empty() => const QuizProgressModel(
        ok: true,
        data: [],
      );

  factory QuizProgressModel.fromJson(dynamic json) {
    if (json is! Map) {
      return QuizProgressModel.empty();
    }

    final map = json.cast<String, dynamic>();
    return QuizProgressModel(
      ok: map['ok'] == true,
      data: _parseData(map['data']),
    );
  }

  QuizProgressData? byQuizId(String quizId) {
    for (final item in data) {
      if (item.quizId == quizId) return item;
    }
    return data.isNotEmpty ? data.first : null;
  }

  static List<QuizProgressData> _parseData(dynamic data) {
    if (data == null) return const [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
              (item) => QuizProgressData.fromJson(item.cast<String, dynamic>()))
          .toList();
    }

    if (data is Map) {
      final map = data.cast<String, dynamic>();
      for (final key in ['progress', 'quizzes', 'items', 'data']) {
        final nested = map[key];
        if (nested is List) {
          return _parseData(nested);
        }
      }
      return [QuizProgressData.fromJson(map)];
    }

    return const [];
  }
}

class QuizProgressData {
  final String id;
  final String quizId;
  final String userId;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final double score;
  final bool completed;
  final int? currentQuestionIndex;

  const QuizProgressData({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.score,
    required this.completed,
    this.currentQuestionIndex,
  });

  factory QuizProgressData.fromJson(Map<String, dynamic> json) {
    return QuizProgressData(
      id: _asString(json['id']),
      quizId: _asString(json['quizId'] ?? json['iKnowQuizId']),
      userId: _asString(json['userId']),
      totalQuestions: _asInt(
        json['totalQuestions'] ??
            json['questionCount'] ??
            json['questionsCount'] ??
            json['total'],
      ),
      answeredQuestions: _asInt(
        json['answeredQuestions'] ??
            json['answeredCount'] ??
            json['answered'] ??
            json['current'],
      ),
      correctAnswers: _asInt(json['correctAnswers'] ?? json['correct']),
      score: _asDouble(json['score']),
      completed: json['completed'] == true,
      currentQuestionIndex: _readCurrentQuestionIndex(json),
    );
  }

  /// 0-based index for [StepProgress].
  ///
  /// Display text uses `stepIndex + 1`, so when [answeredQuestions] is 7
  /// this must be 6 to show «۷ از ۱۰», not 7 («۸ از ۱۰»).
  int get stepIndex {
    final lastIndex = totalQuestions <= 0 ? 0 : totalQuestions - 1;
    if (currentQuestionIndex != null) {
      return currentQuestionIndex!.clamp(0, lastIndex);
    }
    if (answeredQuestions <= 0) return 0;
    return (answeredQuestions - 1).clamp(0, lastIndex);
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _asDouble(dynamic value, [double fallback = 0]) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _readCurrentQuestionIndex(Map<String, dynamic> json) {
    final zeroBased = _asNullableInt(
      json['currentQuestionIndex'] ?? json['currentIndex'],
    );
    if (zeroBased != null) return zeroBased;

    final oneBased = _asNullableInt(json['currentQuestion']);
    if (oneBased == null) return null;
    return (oneBased - 1).clamp(0, 1 << 30);
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null || value is Map || value is List) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
