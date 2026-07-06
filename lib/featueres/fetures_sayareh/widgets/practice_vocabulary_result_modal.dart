import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/practice_vocabulary_bloc/practice_vocabulary_bloc.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/reviewed_vocabularies_screen.dart';

class PracticeVocabularyResultModal extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final List<ReviewedVocabulary> reviewedVocabularies;
  final String courseId;

  const PracticeVocabularyResultModal({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.reviewedVocabularies,
    required this.courseId,
  });

  String _getResultText(double percent) {
    if (percent >= 80) return 'عالی';
    if (percent >= 60) return 'خوب';
    if (percent >= 40) return 'قابل قبول';
    return 'ضعیف';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? MyColors.termsBackgroundDark : Colors.white;
    final scoreBannerColor = isDark
        ? MyColors.paymentHistoryCardHeaderDark
        : const Color(0xFFF3F5F7);
    final primaryTextColor =
        isDark ? MyColors.loginTextPrimaryDark : const Color(0xFF3D495C);
    final secondaryTextColor =
        isDark ? MyColors.loginTextPrimaryDark : const Color(0xFF52617A);

    final double correctPercent =
        totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    final double wrongPercent =
        totalQuestions > 0 ? (wrongAnswers / totalQuestions) * 100 : 0;

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              child: Lottie.asset(
                'assets/lottie/Animation-congrats.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: scoreBannerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'نمره شما : ${_getResultText(correctPercent)}',
                style: MyTextStyle.textHeader16Bold.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'درصد جواب های درست:',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${correctPercent.toStringAsFixed(0)}%',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: secondaryTextColor,
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
                backgroundColor: isDark
                    ? MyColors.profileHeaderDark
                    : const Color(0xFFEFEFEF),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark
                      ? MyColors.quizAnswerCorrectBorderDark
                      : const Color(0xFFADFF99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'درصد جواب های غلط:',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${wrongPercent.toStringAsFixed(0)}%',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: secondaryTextColor,
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
                backgroundColor: isDark
                    ? MyColors.profileHeaderDark
                    : const Color(0xFFEFEFEF),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark
                      ? MyColors.quizAnswerWrongBorderDark
                      : const Color(0xFFFFB199),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.pushReplacementNamed(
                    ReviewedVocabulariesScreen.routeName,
                    arguments: {
                      "reviewedVocabularies": reviewedVocabularies,
                      "courseId": courseId,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? MyColors.loginIconContainerDark
                      : MyColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'مشاهده واژگان مرور شده',
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
