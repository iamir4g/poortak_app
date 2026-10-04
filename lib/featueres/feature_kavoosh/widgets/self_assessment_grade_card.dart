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

  int? _progressFor(QuizLastAttempt attempt) {
    if (attempt.isInProgress) {
      if (attempt.questionCount <= 0) return null;
      return ((attempt.answered / attempt.questionCount) * 100)
          .round()
          .clamp(0, 100);
    }
    if (attempt.isCompleted) {
      return (attempt.score ?? 0).round().clamp(0, 100);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = 350.w;
    final progress =
        lastAttempt != null ? _progressFor(lastAttempt!) : null;
    final isInProgress = lastAttempt?.isInProgress == true;
    final borderRadius = BorderRadius.circular(50.r);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(minHeight: 80.h),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? MyColors.termsBackgroundDark : MyColors.background,
          borderRadius: borderRadius,
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
        child: Stack(
          children: [
            if (progress != null && progress > 0 && progress < 100)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: width * (progress / 100),
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: isDark
                        ? MyColors.lessonCardProgressDark
                        : MyColors.lessonCardProgressLight,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                  _buildTrailing(
                    isDark: isDark,
                    progress: progress,
                    isInProgress: isInProgress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing({
    required bool isDark,
    required int? progress,
    required bool isInProgress,
  }) {
    if (isInProgress) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: MyColors.warning.withValues(alpha: isDark ? 0.25 : 0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: MyColors.warning),
        ),
        child: Text(
          'ادامه',
          style: MyTextStyle.textMatn12Bold.copyWith(color: MyColors.warning),
        ),
      );
    }

    if (progress == null || progress <= 0) {
      return const SizedBox.shrink();
    }

    if (progress == 100) {
      return Container(
        width: 32.w,
        height: 32.h,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 20.r,
        ),
      );
    }

    return Text(
      "%${toPersianDigits('$progress')}",
      style: TextStyle(
        fontFamily: 'IranSans',
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: isDark
            ? MyColors.profileTextPrimaryDark
            : const Color(0xFF53668E),
      ),
    );
  }
}
