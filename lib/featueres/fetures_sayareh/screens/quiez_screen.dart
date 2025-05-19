import 'package:flutter/material.dart';
import 'package:poortak/config/myTextStyle.dart';

class QuizScreen extends StatefulWidget {
  static const routeName = "/quiz";
  final String quizId;
  final String courseId;
  final String title;
  const QuizScreen({
    super.key,
    required this.quizId,
    required this.courseId,
    required this.title,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: MyTextStyle.textHeader16Bold,
        ),
      ),
      body: Column(
        children: [
          Text("Quiz"),
        ],
      ),
    );
  }
}
