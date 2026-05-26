import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SessionItem extends StatelessWidget {
  final String title;
  final bool isLocked;
  final bool isPlaying;
  final VoidCallback onTap;

  const SessionItem({
    super.key,
    required this.title,
    this.isLocked = true,
    this.isPlaying = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isPlaying
              ? (isDark
                  ? MyColors.darkBackgroundSecondary
                  : const Color(0xFFF9F6C6))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isDark && isPlaying
              ? Border.all(color: MyColors.darkBorder)
              : null,
        ),
        child: Row(
          children: [
            // Lock/Status Icon
            Icon(
              isLocked ? Icons.lock : Icons.play_circle_outline,
              color: isLocked
                  ? Colors.amber
                  : (isDark ? MyColors.darkTextSecondary : MyColors.textMatn2),
              size: 20.r,
            ),

            SizedBox(width: 12.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: MyTextStyle.textMatn12W500.copyWith(
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Play Arrow Icon
            if (!isLocked)
              Icon(
                Icons.play_arrow,
                size: 16.r,
                color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
              ),
          ],
        ),
      ),
    );
  }
}
