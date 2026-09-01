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

    final steps = totalSteps <= 0 ? 1 : totalSteps;
    final index = currentIndex.clamp(0, steps - 1);
    final widthFactor = ((index + 1) / steps).clamp(0.0, 1.0);

    return Container(
      height: 15.h,
      width: 300.w,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? MyColors.background5 : MyColors.background4,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          FractionallySizedBox(
            widthFactor: widthFactor,
            alignment: AlignmentDirectional.centerStart,
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
