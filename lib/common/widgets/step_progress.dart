import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';

class StepProgress extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;

  const StepProgress(
      {super.key, required this.currentIndex, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? MyColors.paymentHistoryCardHeaderDark
        : MyColors.vocabularyProgressFill.withValues(alpha: 0.35);
    final fillColor = MyColors.vocabularyProgressFill;

    return Container(
      height: 15.h,
      width: 300.w,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          FractionallySizedBox(
            widthFactor: (currentIndex + 1) / totalSteps,
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
