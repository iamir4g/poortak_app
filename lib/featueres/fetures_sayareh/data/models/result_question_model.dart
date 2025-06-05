// To parse this JSON data, do
//
//     final resultQuestion = resultQuestionFromJson(jsonString);

import 'dart:convert';

ResultQuestion resultQuestionFromJson(String str) =>
    ResultQuestion.fromJson(json.decode(str));

String resultQuestionToJson(ResultQuestion data) => json.encode(data.toJson());

class ResultQuestion {
  bool ok;
  Meta meta;
  Data data;

  ResultQuestion({
    required this.ok,
    required this.meta,
    required this.data,
  });

  factory ResultQuestion.fromJson(Map<String, dynamic> json) => ResultQuestion(
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
  int totalQuestions;
  int answeredQuestions;
  int correctAnswers;
  int score;
  List<AnswerElement> answers;

  Data({
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.score,
    required this.answers,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalQuestions: json["totalQuestions"],
        answeredQuestions: json["answeredQuestions"],
        correctAnswers: json["correctAnswers"],
        score: json["score"],
        answers: List<AnswerElement>.from(
            json["answers"].map((x) => AnswerElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalQuestions": totalQuestions,
        "answeredQuestions": answeredQuestions,
        "correctAnswers": correctAnswers,
        "score": score,
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
      };
}

class AnswerElement {
  String id;
  String userId;
  String questionId;
  String answerId;
  bool isCorrect;
  DateTime createdAt;
  Question question;
  AnswerAnswer answer;

  AnswerElement({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.answerId,
    required this.isCorrect,
    required this.createdAt,
    required this.question,
    required this.answer,
  });

  factory AnswerElement.fromJson(Map<String, dynamic> json) => AnswerElement(
        id: json["id"],
        userId: json["userId"],
        questionId: json["questionId"],
        answerId: json["answerId"],
        isCorrect: json["isCorrect"],
        createdAt: DateTime.parse(json["createdAt"]),
        question: Question.fromJson(json["question"]),
        answer: AnswerAnswer.fromJson(json["answer"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "questionId": questionId,
        "answerId": answerId,
        "isCorrect": isCorrect,
        "createdAt": createdAt.toIso8601String(),
        "question": question.toJson(),
        "answer": answer.toJson(),
      };
}

class AnswerAnswer {
  String id;
  String questionId;
  String title;
  bool isCorrect;
  DateTime createdAt;
  DateTime updatedAt;

  AnswerAnswer({
    required this.id,
    required this.questionId,
    required this.title,
    required this.isCorrect,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnswerAnswer.fromJson(Map<String, dynamic> json) => AnswerAnswer(
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

  Question({
    required this.id,
    required this.quizId,
    required this.title,
    required this.explanation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        quizId: json["quizId"],
        title: json["title"],
        explanation: json["explanation"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quizId": quizId,
        "title": title,
        "explanation": explanation,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}
