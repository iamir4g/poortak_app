import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:shimmer/shimmer.dart';

class ImageSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ImageSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? MyColors.darkCardBackground : const Color(0xFFE8E8E8);
    final highlightColor = isDark
        ? MyColors.paymentHistoryCardHeaderDark
        : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}
