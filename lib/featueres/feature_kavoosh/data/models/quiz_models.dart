class QuizCategory {
  final String id;
  final String title;
  final String description;
  final String type;
  final int order;
  final String? thumbnailId;
  final String? backgroundImageId;
  final int quizCount;

  const QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    required this.quizCount,
    this.thumbnailId,
    this.backgroundImageId,
  });

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'CATEGORY',
      order: _asInt(json['order']),
      thumbnailId: _asNullableString(json['thumbnailId']),
      backgroundImageId: _asNullableString(json['backgroundImageId']),
      quizCount: _asInt(json['quizCount']),
    );
  }
}

class QuizLastAttempt {
  final String attemptId;
  final String status;
  final String state;
  final int questionCount;
  final double? score;
  final String? completedAt;
  final int answered;
  final int correct;
  final int wrong;

  const QuizLastAttempt({
    required this.attemptId,
    required this.status,
    required this.state,
    required this.questionCount,
    required this.answered,
    required this.correct,
    required this.wrong,
    this.score,
    this.completedAt,
  });

  bool get isInProgress => state == 'in-progress' || status == 'Started';
  bool get isCompleted => state == 'completed' || status == 'Completed';
  bool get isPassed => isCompleted && (score ?? 0) >= 70;

  factory QuizLastAttempt.fromJson(Map<String, dynamic> json) {
    return QuizLastAttempt(
      attemptId: json['attemptId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      questionCount: _asInt(json['questionCount']),
      score: _asDoubleOrNull(json['score']),
      completedAt: _asNullableString(json['completedAt']),
      answered: _asInt(json['answered']),
      correct: _asInt(json['correct']),
      wrong: _asInt(json['wrong']),
    );
  }
}

class QuizSummary {
  final String id;
  final String title;
  final String description;
  final int order;
  final String? thumbnailId;
  final String? publishedAt;
  final String categoryId;
  final String categoryTitle;
  final int questionCount;
  final QuizLastAttempt? lastAttempt;

  const QuizSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.categoryId,
    required this.categoryTitle,
    required this.questionCount,
    this.thumbnailId,
    this.publishedAt,
    this.lastAttempt,
  });

  factory QuizSummary.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final categoryMap =
        category is Map ? category.cast<String, dynamic>() : null;
    final lastAttemptJson = json['lastAttempt'];

    return QuizSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      order: _asInt(json['order']),
      thumbnailId: _asNullableString(json['thumbnailId']),
      publishedAt: _asNullableString(json['publishedAt']),
      categoryId: json['categoryId']?.toString() ??
          categoryMap?['id']?.toString() ??
          '',
      categoryTitle: categoryMap?['title']?.toString() ?? '',
      questionCount: _asInt(json['questionCount']),
      lastAttempt: lastAttemptJson is Map
          ? QuizLastAttempt.fromJson(lastAttemptJson.cast<String, dynamic>())
          : null,
    );
  }
}

class QuizAnswerOption {
  final String id;
  final String title;

  const QuizAnswerOption({
    required this.id,
    required this.title,
  });

  factory QuizAnswerOption.fromJson(Map<String, dynamic> json) {
    return QuizAnswerOption(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

class QuizQuestion {
  final String id;
  final String title;
  final String? description;
  final int order;
  final List<QuizAnswerOption> answers;

  const QuizQuestion({
    required this.id,
    required this.title,
    required this.order,
    required this.answers,
    this.description,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: _asNullableString(json['description']),
      order: _asInt(json['order']),
      answers: (json['answers'] as List? ?? [])
          .whereType<Map>()
          .map((e) => QuizAnswerOption.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class QuizAttemptInfo {
  final String id;
  final String status;
  final String state;
  final double? score;
  final String? completedAt;

  const QuizAttemptInfo({
    required this.id,
    required this.status,
    required this.state,
    this.score,
    this.completedAt,
  });

  factory QuizAttemptInfo.fromJson(Map<String, dynamic> json) {
    return QuizAttemptInfo(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      score: _asDoubleOrNull(json['score']),
      completedAt: _asNullableString(json['completedAt']),
    );
  }
}

class QuizStats {
  final int total;
  final int answered;

  const QuizStats({
    required this.total,
    required this.answered,
  });

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      total: _asInt(json['total']),
      answered: _asInt(json['answered']),
    );
  }
}

class QuizAttemptSession {
  final QuizAttemptInfo attempt;
  final QuizQuestion? question;
  final QuizStats stats;

  const QuizAttemptSession({
    required this.attempt,
    required this.stats,
    this.question,
  });

  factory QuizAttemptSession.fromJson(Map<String, dynamic> json) {
    final questionJson = json['question'];
    final statsJson = json['stats'];
    final attemptJson = json['attempt'];

    return QuizAttemptSession(
      attempt: QuizAttemptInfo.fromJson(
        attemptJson is Map
            ? attemptJson.cast<String, dynamic>()
            : <String, dynamic>{},
      ),
      question: questionJson is Map
          ? QuizQuestion.fromJson(questionJson.cast<String, dynamic>())
          : null,
      stats: QuizStats.fromJson(
        statsJson is Map
            ? statsJson.cast<String, dynamic>()
            : <String, dynamic>{},
      ),
    );
  }
}

class QuizAnswerResult {
  final bool correct;
  final String correctAnswerId;
  final QuizStats stats;

  const QuizAnswerResult({
    required this.correct,
    required this.correctAnswerId,
    required this.stats,
  });

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'];
    return QuizAnswerResult(
      correct: json['correct'] == true,
      correctAnswerId: json['correctAnswerId']?.toString() ?? '',
      stats: QuizStats.fromJson(
        statsJson is Map
            ? statsJson.cast<String, dynamic>()
            : <String, dynamic>{},
      ),
    );
  }
}

class QuizAttemptResult {
  final String attemptId;
  final String status;
  final String state;
  final int questionCount;
  final double score;
  final String? completedAt;
  final int answered;
  final int correct;
  final int wrong;

  const QuizAttemptResult({
    required this.attemptId,
    required this.status,
    required this.state,
    required this.questionCount,
    required this.score,
    required this.answered,
    required this.correct,
    required this.wrong,
    this.completedAt,
  });

  factory QuizAttemptResult.fromJson(Map<String, dynamic> json) {
    return QuizAttemptResult(
      attemptId: json['attemptId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      questionCount: _asInt(json['questionCount']),
      score: _asDoubleOrNull(json['score']) ?? 0,
      completedAt: _asNullableString(json['completedAt']),
      answered: _asInt(json['answered']),
      correct: _asInt(json['correct']),
      wrong: _asInt(json['wrong']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty || text == 'null') return null;
  return text;
}
