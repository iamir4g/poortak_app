import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/data/models/quiz_models.dart';

class SelfAssessmentGradeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final QuizLastAttempt? lastAttempt;
  final String? subtitle;

  const SelfAssessmentGradeCard({
    super.key,
    required this.title,
    required this.onTap,
    this.lastAttempt,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(minHeight: 80.h),
        decoration: BoxDecoration(
          color: isDark ? MyColors.termsBackgroundDark : MyColors.background,
          borderRadius: BorderRadius.circular(50.r),
          border: isDark ? Border.all(color: MyColors.darkBorder) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: Row(
          children: [
            buildImageFromAssetOrEmbeddedSvg(
              'assets/images/points/quiz_icon.png',
              width: 40.r,
              height: 40.r,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: MyTextStyle.textMatn18Bold.copyWith(
                        color: isDark ? MyColors.darkTextPrimary : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: MyTextStyle.textMatn12Bold.copyWith(
                          color: isDark
                              ? MyColors.darkTextSecondary
                              : MyColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (lastAttempt != null) _buildBadge(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(bool isDark) {
    final attempt = lastAttempt!;
    final Color color;
    final String label;

    if (attempt.isInProgress) {
      color = MyColors.warning;
      label = 'ادامه';
    } else if (attempt.isPassed) {
      color = MyColors.success;
      label = '${toPersianDigits((attempt.score ?? 0).round().toString())}٪';
    } else if (attempt.isCompleted) {
      color = MyColors.error;
      label = '${toPersianDigits((attempt.score ?? 0).round().toString())}٪';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: MyTextStyle.textMatn12Bold.copyWith(color: color),
      ),
    );
  }
}
