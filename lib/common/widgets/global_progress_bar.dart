import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class GlobalProgressBar extends StatelessWidget {
  final double percentage;
  final double? height;
  final double? width;
  final Color progressColor;
  final Color backgroundColor;
  final TextStyle? textStyle;

  const GlobalProgressBar({
    super.key,
    required this.percentage,
    this.height,
    this.width,
    this.progressColor = MyColors.progressBarColor,
    this.backgroundColor = MyColors.progressBarBackground,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? 10.h;
    final barWidth = width ?? 100.w;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${percentage.toInt()}%",
          style: textStyle ??
              MyTextStyle.textProgressBar.copyWith(color: progressColor),
        ),
        SizedBox(width: Dimens.tiny),
        SizedBox(
          width: barWidth,
          height: barHeight,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(barHeight / 2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(barHeight / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
