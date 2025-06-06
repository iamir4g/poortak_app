import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'dart:developer';

class QuizAnswerItem extends StatefulWidget {
  final String title;
  final String id;
  final bool isSelected;
  final bool isCorrect;
  final bool showFeedback;
  final bool isWrongSelected;
  final String selectedAnswerId;

  const QuizAnswerItem({
    super.key,
    required this.title,
    required this.id,
    this.isSelected = false,
    this.isCorrect = false,
    this.showFeedback = false,
    this.isWrongSelected = false,
    this.selectedAnswerId = "",
  });

  @override
  State<QuizAnswerItem> createState() => _QuizAnswerItemState();
}

class _QuizAnswerItemState extends State<QuizAnswerItem> {
  @override
  void initState() {
    super.initState();
    _updateAppearance();
  }

  @override
  void didUpdateWidget(QuizAnswerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFeedback != oldWidget.showFeedback ||
        widget.isSelected != oldWidget.isSelected ||
        widget.isCorrect != oldWidget.isCorrect) {
      _updateAppearance();
    }
  }

  void _updateAppearance() {
    // Update the appearance of the widget based on the values of isSelected, isCorrect, isWrong, and showFeedback
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    Color bgColor = const Color(0xFFF6F9FE);
    // log("widget.id: ${widget.id}");
    // log("widget.showFeedback: ${widget.showFeedback}");
    // log("widget.isCorrect: ${widget.isCorrect}");
    // log("widget.isSelected: ${widget.isSelected}");
    if (widget.showFeedback) {
      if (widget.isCorrect) {
        borderColor = const Color(0xFF6FC845); // green
        bgColor = const Color(0xFFEDFAEB); // light green
      } else if (widget.id == widget.selectedAnswerId &&
          widget.isWrongSelected) {
        borderColor = const Color(0xFFE96217); // red
        bgColor = const Color(0xFFFDEFE8); // light red
      }
    } else if (widget.isSelected) {
      borderColor = MyColors.primary;
    }
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF494E6A),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
