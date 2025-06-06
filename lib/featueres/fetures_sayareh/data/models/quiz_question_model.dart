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

  factory QuizesQuestion.fromJson(Map<String, dynamic> json) => QuizesQuestion(
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
        id: json["id"],
        quizId: json["quizId"],
        title: json["title"],
        explanation: json["explanation"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        answers:
            List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
        correctAnswer: json["correctAnswer"] == null
            ? null
            : Answer.fromJson(json["correctAnswer"]),
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
        id: json["id"],
        title: json["title"],
        questionId: json["questionId"],
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
