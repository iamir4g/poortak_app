import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/quizzes_screen.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/featueres/fetures_sayareh/repositories/sayareh_repository.dart';

class QuizResultModal extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final double score;
  final String courseId;
  final String quizId;

  const QuizResultModal({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.courseId,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentages
    final double correctPercent =
        totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    final double wrongPercent = totalQuestions > 0
        ? ((totalQuestions - correctAnswers) / totalQuestions) * 100
        : 0;

    String getResultText(double percent) {
      if (percent >= 80) return 'عالی';
      if (percent >= 60) return 'خوب';
      if (percent >= 40) return 'قابل قبول';
      return 'ضعیف';
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation placeholder
            SizedBox(
              height: 100.h,
              child: Lottie.asset(
                'assets/lottie/Animation-congrats.json', // Replace with your actual Lottie file
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: Dimens.medium.h),
            Text(
              'نمره شما : ${getResultText(correctPercent)}',
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: const Color(0xFF3D495C),
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Dimens.medium.h),
            // Correct answers percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'درصد جواب های درست:',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '${correctPercent.toStringAsFixed(0)}%',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(
                value: correctPercent / 100,
                minHeight: 14.h,
                backgroundColor: const Color(0xFFEFEFEF),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFADFF99)),
              ),
            ),
            SizedBox(height: Dimens.medium.h),
            // Wrong answers percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'درصد جواب های غلط:',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '${wrongPercent.toStringAsFixed(0)}%',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: const Color(0xFF52617A),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(
                value: wrongPercent / 100,
                minHeight: 14.h,
                backgroundColor: const Color(0xFFEFEFEF),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB199)),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () async {
                  await locator<SayarehRepository>()
                      .deleteQuizResult(courseId, quizId);
                  if (context.mounted) {
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName(QuizzesScreen.routeName));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  'بازگشت به لیست آزمون ها',
                  style: MyTextStyle.textHeader16Bold.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
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
