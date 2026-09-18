// To parse this JSON data, do
//
//     final answerQuestion = answerQuestionFromJson(jsonString);

import 'dart:convert';

AnswerQuestion answerQuestionFromJson(String str) =>
    AnswerQuestion.fromJson(json.decode(str));

String answerQuestionToJson(AnswerQuestion data) => json.encode(data.toJson());

class AnswerQuestion {
  bool ok;
  Meta meta;
  Data data;

  AnswerQuestion({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory AnswerQuestion.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    final Map<String, dynamic> dataJson = rawData is Map
        ? rawData.cast<String, dynamic>()
        : <String, dynamic>{};

    return AnswerQuestion(
      ok: json["ok"] == true,
      meta:
          Meta.fromJson((json["meta"] as Map?)?.cast<String, dynamic>() ?? {}),
      data: Data.fromJson(dataJson),
    );
  }

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data.toJson(),
      };
}

class Data {
  Question question;
  CorrectAnswer correctAnswer;
  bool correct;
  Question? nextQuestion;
  AnswerStats? stats;

  Data({
    required this.question,
    required this.correctAnswer,
    required this.correct,
    this.nextQuestion,
    this.stats,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        question: Question.fromJson(
          (json["question"] as Map?)?.cast<String, dynamic>() ?? {},
        ),
        correctAnswer: CorrectAnswer.fromJson(
          (json["correctAnswer"] as Map?)?.cast<String, dynamic>() ?? {},
        ),
        correct: json["correct"] == true,
        nextQuestion: json["nextQuestion"] != null
            ? Question.fromJson(
                (json["nextQuestion"] as Map).cast<String, dynamic>(),
              )
            : null,
        stats: json["stats"] != null
            ? AnswerStats.fromJson(
                (json["stats"] as Map).cast<String, dynamic>(),
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        "question": question.toJson(),
        "correctAnswer": correctAnswer.toJson(),
        "correct": correct,
        "nextQuestion": nextQuestion?.toJson(),
        "stats": stats?.toJson(),
      };
}

class AnswerStats {
  final int all;
  final int answered;
  final int correct;

  const AnswerStats({
    required this.all,
    required this.answered,
    required this.correct,
  });

  factory AnswerStats.fromJson(Map<String, dynamic> json) => AnswerStats(
        all: _asInt(json["all"] ?? json["total"] ?? json["totalQuestions"]),
        answered: _asInt(
          json["answered"] ??
              json["answeredQuestions"] ??
              json["answeredCount"],
        ),
        correct: _asInt(json["correct"] ?? json["correctAnswers"]),
      );

  Map<String, dynamic> toJson() => {
        "all": all,
        "answered": answered,
        "correct": correct,
      };

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class CorrectAnswer {
  String id;
  String questionId;
  String title;
  bool isCorrect;
  DateTime createdAt;
  DateTime updatedAt;

  CorrectAnswer({
    required this.id,
    required this.questionId,
    required this.title,
    required this.isCorrect,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) => CorrectAnswer(
        id: json["id"]?.toString() ?? "",
        questionId: json["questionId"]?.toString() ?? "",
        title: json["title"]?.toString() ?? "",
        isCorrect: json["isCorrect"] == true,
        createdAt: DateTime.tryParse((json["createdAt"] ?? "").toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.tryParse((json["updatedAt"] ?? "").toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "questionId": questionId,
        "title": title,
        "isCorrect": isCorrect,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Question {
  String id;
  String quizId;
  String title;
  dynamic explanation;
  DateTime createdAt;
  DateTime updatedAt;
  List<Answer>? answers;

  Question({
    required this.id,
    required this.quizId,
    required this.title,
    required this.explanation,
    required this.createdAt,
    required this.updatedAt,
    this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"]?.toString() ?? "",
        quizId: json["quizId"]?.toString() ?? "",
        title: json["title"]?.toString() ?? "",
        explanation: json["explanation"],
        createdAt: DateTime.tryParse((json["createdAt"] ?? "").toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.tryParse((json["updatedAt"] ?? "").toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        answers: json["answers"] == null
            ? []
            : List<Answer>.from(
                (json["answers"] as List).map(
                  (x) => Answer.fromJson((x as Map).cast<String, dynamic>()),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quizId": quizId,
        "title": title,
        "explanation": explanation,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "answers": answers == null
            ? []
            : List<dynamic>.from(answers!.map((x) => x.toJson())),
      };
}

class Answer {
  String id;
  String title;
  String questionId;

  Answer({
    required this.id,
    required this.title,
    required this.questionId,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: json["id"]?.toString() ?? "",
        title: json["title"]?.toString() ?? "",
        questionId: json["questionId"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "questionId": questionId,
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
