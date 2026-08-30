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

  factory AnswerQuestion.fromJson(Map<String, dynamic> json) => AnswerQuestion(
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
  Question question;
  CorrectAnswer correctAnswer;
  bool correct;
  Question? nextQuestion;

  Data({
    required this.question,
    required this.correctAnswer,
    required this.correct,
    this.nextQuestion,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        question: Question.fromJson(json["question"]),
        correctAnswer: CorrectAnswer.fromJson(json["correctAnswer"]),
        correct: json["correct"],
        nextQuestion: json["nextQuestion"] != null
            ? Question.fromJson(json["nextQuestion"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "question": question.toJson(),
        "correctAnswer": correctAnswer.toJson(),
        "correct": correct,
        "nextQuestion": nextQuestion?.toJson(),
      };
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
        id: json["id"],
        questionId: json["questionId"],
        title: json["title"],
        isCorrect: json["isCorrect"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
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
        id: json["id"],
        quizId: json["quizId"],
        title: json["title"],
        explanation: json["explanation"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        answers: json["answers"] == null
            ? []
            : List<Answer>.from(
                json["answers"]!.map((x) => Answer.fromJson(x))),
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
