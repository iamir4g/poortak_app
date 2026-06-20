import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';

class VideoProgressBarWidget extends StatelessWidget {
  final bool isVisible;
  final double progress;
  final String label;

  const VideoProgressBarWidget({
    super.key,
    required this.isVisible,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1;

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 350.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '${((progress.clamp(0.0, 1.0) * 100).toInt())}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6.h,
              backgroundColor:
                  isDark ? MyColors.loginIconContainerDark : Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(MyColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class DecryptionProgressBarWidget extends StatelessWidget {
  final bool isVisible;
  final double progress;

  const DecryptionProgressBarWidget({
    super.key,
    required this.isVisible,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? MyColors.profileTextPrimaryDark : MyColors.textMatn1;

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 350.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'در حال رمزگشایی...',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '${((progress.clamp(0.0, 1.0) * 100).toInt())}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6.h,
              backgroundColor:
                  isDark ? MyColors.loginIconContainerDark : Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(MyColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
