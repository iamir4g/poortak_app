import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
class LessonCardWidget extends StatelessWidget {
  final String iconPath;
  final String englishLabel;
  final String persianLabel;
  final VoidCallback onTap;
  final Widget? badge;
  final int? progress;

  const LessonCardWidget({
    super.key,
    required this.iconPath,
    required this.englishLabel,
    required this.persianLabel,
    required this.onTap,
    this.badge,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 359.w,
        height: 104.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 0),
              blurRadius: 4.r,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (progress != null && progress! > 0 && progress! < 100)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 359.w * (progress! / 100),
                  color: const Color(
                      0xFFE3F2FD), // Light blue color for progress background
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 28.w),
              child: Row(
                children: [
                  badge != null
                      ? Stack(
                          children: [
                            Image.asset(
                              iconPath,
                              width: 48.0.r,
                              height: 48.0.r,
                            ),
                            Positioned(
                              top: 5.h,
                              left: 14.w,
                              child: badge!,
                            ),
                          ],
                        )
                      : Image.asset(
                          iconPath,
                          width: 48.0.r,
                          height: 48.0.r,
                        ),
                  SizedBox(width: 18.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        englishLabel,
                        style: MyTextStyle.textMatn12W500.copyWith(
                          color: const Color(0xFFA3AFC2),
                        ),
                      ),
                      Text(
                        persianLabel,
                        style: MyTextStyle.textMatn18Bold.copyWith(
                          color: const Color(0xFF29303D),
                        ),
                      )
                    ],
                  ),
                  if (progress != null && progress! > 0) ...[
                    const Spacer(),
                    if (progress == 100)
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50), // Green color
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24.r,
                        ),
                      )
                    else
                      Text(
                        "%$progress",
                        style: TextStyle(
                          fontFamily: 'IranSans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF53668E),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
