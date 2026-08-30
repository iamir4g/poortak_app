// To parse this JSON data, do
//
//     final quizesQuestion = quizesQuestionFromJson(jsonString);

import 'dart:convert';

QuizesQuestion quizesQuestionFromJson(String str) =>
    QuizesQuestion.fromJson(json.decode(str));

String quizesQuestionToJson(QuizesQuestion data) => json.encode(data.toJson());

class QuizesQuestion {
  bool ok;
  Meta meta;
  Data data;

  QuizesQuestion({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory QuizesQuestion.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    final Map<String, dynamic> dataJson =
        rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};

    final Map<String, dynamic> questionJson = _extractQuestionJson(dataJson);

    return QuizesQuestion(
      ok: json["ok"] ?? false,
      meta:
          Meta.fromJson((json["meta"] as Map?)?.cast<String, dynamic>() ?? {}),
      data: Data.fromJson(questionJson),
    );
  }

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "meta": meta.toJson(),
        "data": data.toJson(),
      };

  static Map<String, dynamic> _extractQuestionJson(
    Map<String, dynamic> dataJson,
  ) {
    final hasQuestionShape =
        dataJson.containsKey("id") && dataJson.containsKey("answers");
    if (hasQuestionShape) {
      return dataJson;
    }

    final candidates = <dynamic>[
      dataJson["question"],
      dataJson["currentQuestion"],
      dataJson["lastQuestion"],
      dataJson["nextQuestion"],
      dataJson["data"],
    ];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic> &&
          candidate.containsKey("id") &&
          candidate.containsKey("answers")) {
        return candidate;
      }
      if (candidate is Map) {
        final casted = candidate.cast<String, dynamic>();
        if (casted.containsKey("id") && casted.containsKey("answers")) {
          return casted;
        }
      }
    }

    return dataJson;
  }
}

class Data {
  String id;
  String quizId;
  String title;
  dynamic explanation;
  DateTime createdAt;
  DateTime updatedAt;
  List<Answer> answers;
  Answer? correctAnswer;

  Data({
    required this.id,
    required this.quizId,
    required this.title,
    required this.explanation,
    required this.createdAt,
    required this.updatedAt,
    required this.answers,
    this.correctAnswer,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? "",
        quizId: json["quizId"] ?? "",
        title: json["title"] ?? "",
        explanation: json["explanation"],
        createdAt: DateTime.tryParse((json["createdAt"] ?? "").toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.tryParse((json["updatedAt"] ?? "").toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        answers: ((json["answers"] as List?) ?? [])
            .map((x) => Answer.fromJson((x as Map).cast<String, dynamic>()))
            .toList(),
        correctAnswer: json["correctAnswer"] == null
            ? null
            : Answer.fromJson(
                (json["correctAnswer"] as Map).cast<String, dynamic>(),
              ),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quizId": quizId,
        "title": title,
        "explanation": explanation,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
        "correctAnswer": correctAnswer?.toJson(),
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
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        questionId: json["questionId"] ?? "",
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
