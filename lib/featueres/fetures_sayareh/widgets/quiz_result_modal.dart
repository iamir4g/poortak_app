import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quizzes_screen.dart';

class QuizResultModal extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final double score;
  final String courseId;

  const QuizResultModal({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentages
    final double correctPercent =
        totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    final double wrongPercent = totalQuestions > 0
        ? ((totalQuestions - correctAnswers) / totalQuestions) * 100
        : 0;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation placeholder
            SizedBox(
              height: 100,
              child: Lottie.asset(
                'assets/lottie/Animation-congrats.json', // Replace with your actual Lottie file
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'نمره شما : ${correctPercent >= 60 ? 'قابل قبول' : 'نیاز به تلاش بیشتر'}',
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: const Color(0xFF3D495C),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Correct answers percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'درصد جواب های درست:',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${correctPercent.toStringAsFixed(0)}%',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: correctPercent / 100,
                minHeight: 14,
                backgroundColor: const Color(0xFFEFEFEF),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFADFF99)),
              ),
            ),
            const SizedBox(height: 16),
            // Wrong answers percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'درصد جواب های غلط:',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${wrongPercent.toStringAsFixed(0)}%',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: wrongPercent / 100,
                minHeight: 14,
                backgroundColor: const Color(0xFFEFEFEF),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB199)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, QuizzesScreen.routeName,
                      arguments: {"courseId": courseId});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'بازگشت به لیست آزمون ها',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
