import 'package:flutter/material.dart';

class QuizzesScreen extends StatefulWidget {
  static const routeName = "/quizzes";
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Quizzes"),
        ],
      ),
    );
  }
}
