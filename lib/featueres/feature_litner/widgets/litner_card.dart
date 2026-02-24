import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myTextStyle.dart';

class LitnerCard extends StatelessWidget {
  final LinearGradient gradient;
  final String icon;
  final String number;
  final String label;
  final String subLabel;
  final VoidCallback onTap;
  const LitnerCard({
    required this.gradient,
    required this.icon,
    required this.number,
    required this.label,
    required this.subLabel,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 359.w,
        height: 143.h,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            // Right: White circle with image
            Padding(
              padding: EdgeInsets.only(right: 16.w, left: 8.w),
              child: Container(
                width: 79.w,
                height: 79.h,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    width: 44.w,
                    height: 44.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Center/Left: Texts
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: 16.w, left: 24.w, top: 32.h, bottom: 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          number,
                          style: MyTextStyle.textMatn18Bold.copyWith(
                            fontSize: 20.sp,
                            color: const Color(0xFF29303D),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          label,
                          style: MyTextStyle.textMatn17W700.copyWith(
                            fontSize: 20.sp,
                            color: const Color(0xFF29303D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      subLabel,
                      style: MyTextStyle.textMatn12W500.copyWith(
                        color: const Color(0xFF52617A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LitnerTodayCard extends StatelessWidget {
  final String number;
  final String label;
  final String buttonText;
  final String imageAsset;
  final VoidCallback onTap;
  const LitnerTodayCard({
    this.number = '۳',
    this.label = 'کارت های امروز',
    this.buttonText = 'شروع',
    this.imageAsset = 'assets/images/litner/flash-card.png',
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 359.w,
        height: 112.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF5DB), Color(0xFFFEE8DB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            // Right: White circle with image
            Padding(
              padding: EdgeInsets.only(right: 16.w, left: 8.w),
              child: Container(
                width: 79.w,
                height: 79.h,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    imageAsset,
                    width: 42.w,
                    height: 41.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Center: Texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: MyTextStyle.textMatn18Bold.copyWith(
                      fontSize: 20.sp,
                      color: const Color(0xFF29303D),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    label,
                    style: MyTextStyle.textMatn12W500.copyWith(
                      color: const Color(0xFF52617A),
                    ),
                  ),
                ],
              ),
            ),
            // Left: Button
            Padding(
              padding: EdgeInsets.only(left: 18.w, right: 8.w),
              child: Container(
                width: 105.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA73F),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  style: MyTextStyle.textMatnBtn.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
