import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SelfAssessmentGradeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SelfAssessmentGradeCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        height: 80.h,
        decoration: BoxDecoration(
          color: MyColors.background,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/quiz_icon.png',
              width: 40.w,
              height: 40.h,
            ),
            Padding(
              padding: EdgeInsets.only(right: 16.0.w),
              child: Text(
                title,
                style: MyTextStyle.textMatn18Bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
