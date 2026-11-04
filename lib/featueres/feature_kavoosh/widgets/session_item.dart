import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
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
            Icon(Icons.arrow_right, size: 20.r, color: MyColors.background5),
            // Title (سمت راست در RTL)
            Expanded(
              child: Text(
                title,
                style: MyTextStyle.textMatn12W500.copyWith(
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),

            SizedBox(width: 12.w),

            // قفل / پخش — سمت چپ در RTL
            if (isLocked)
              SizedBox(
                width: 20.r,
                height: 20.r,
                child: buildImageFromAssetOrEmbeddedSvg(
                  'assets/images/lock_image.svg',
                  width: 20.r,
                  height: 20.r,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: MyColors.brandPrimary.withValues(alpha: 0.1),
                  border: Border.all(color: MyColors.brandPrimary),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                width: 60.r,
                height: 30.r,
                child: Center(
                  child: Text(
                    "تماشا",
                    style: MyTextStyle.textMatn12W500.copyWith(
                      color: MyColors.primary,
                    ),
                  ),
                ),
              )
            // Icon(
            //   Icons.play_arrow,
            //   size: 20.r,
            //   color: isDark ? MyColors.darkTextSecondary : MyColors.text4,
            // ),
          ],
        ),
      ),
    );
  }
}
