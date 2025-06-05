import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class QuizResultModal extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int score;

  const QuizResultModal({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نتیجه آزمون',
              style: MyTextStyle.textHeader16Bold,
            ),
            const SizedBox(height: 20),
            Text(
              'تعداد سوالات: $totalQuestions',
              style: MyTextStyle.textHeader16Bold,
            ),
            const SizedBox(height: 10),
            Text(
              'پاسخ های درست: $correctAnswers',
              style: MyTextStyle.textHeader16Bold,
            ),
            const SizedBox(height: 10),
            Text(
              'امتیاز: $score',
              style: MyTextStyle.textHeader16Bold,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'بازگشت به لیست آزمون ها',
                style: MyTextStyle.textHeader16Bold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
