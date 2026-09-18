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

  /// 1-based current question number from API `answered` (e.g. 7 → «۷ از ۱۰»).
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
    final total = _asInt(
      json['all'] ??
          json['totalQuestions'] ??
          json['questionCount'] ??
          json['questionsCount'] ??
          json['total'],
    );
    final answered = _asInt(
      json['answered'] ??
          json['currentQuestion'] ??
          json['answeredQuestions'] ??
          json['answeredCount'] ??
          json['current'],
    );

    return QuizProgressData(
      id: _asString(json['id']),
      quizId: _asString(json['quizId'] ?? json['iKnowQuizId']),
      userId: _asString(json['userId']),
      totalQuestions: total,
      answeredQuestions: answered,
      correctAnswers: _asInt(json['correctAnswers'] ?? json['correct']),
      score: _asDouble(json['score']),
      completed: json['completed'] == true,
      currentQuestionIndex:
          _readCurrentQuestionIndex(json) ?? _oneBasedToZeroBased(answered),
    );
  }

  /// 1-based question number for UI («۷ از ۱۰»).
  int get currentQuestion {
    if (totalQuestions <= 0) return 1;
    if (answeredQuestions > 0) {
      return answeredQuestions.clamp(1, totalQuestions);
    }
    return (stepIndex + 1).clamp(1, totalQuestions);
  }

  /// 0-based index for [StepProgress].
  int get stepIndex {
    final lastIndex = totalQuestions <= 0 ? 0 : totalQuestions - 1;
    if (currentQuestionIndex != null) {
      return currentQuestionIndex!.clamp(0, lastIndex);
    }
    return _oneBasedToZeroBased(answeredQuestions).clamp(0, lastIndex);
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

  static int _oneBasedToZeroBased(int oneBased) {
    if (oneBased <= 0) return 0;
    return oneBased - 1;
  }

  static int? _readCurrentQuestionIndex(Map<String, dynamic> json) {
    final zeroBased = _asNullableInt(
      json['currentQuestionIndex'] ?? json['currentIndex'],
    );
    if (zeroBased != null) return zeroBased;
    return null;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null || value is Map || value is List) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
