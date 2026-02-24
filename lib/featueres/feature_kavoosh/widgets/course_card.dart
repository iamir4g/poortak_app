import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/video_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.title,
    this.imagePath,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.pushNamed(
              context,
              VideoDetailScreen.routeName,
              arguments: {'title': title},
            );
          },
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(left: 16.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(20.r)),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20.r)),
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child:
                            Icon(Icons.image, color: Colors.grey, size: 40.r),
                      ),
              ),
            ),
            // Title
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0.r),
                child: Center(
                  child: Text(
                    title,
                    style: MyTextStyle.textMatn12Bold.copyWith(
                      color: MyColors.textMatn2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
