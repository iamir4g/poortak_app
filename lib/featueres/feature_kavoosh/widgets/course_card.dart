import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/dimens.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        margin: EdgeInsets.only(left: Dimens.medium),
        constraints: BoxConstraints(minHeight: 180.h),
        decoration: BoxDecoration(
          color: isDark
              ? MyColors.termsBackgroundDark
              : (backgroundColor ?? Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border:
              isDark ? Border.all(color: MyColors.darkBorder) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Placeholder
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: isDark
                    ? MyColors.darkBackgroundSecondary
                    : Colors.grey[200],
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
                          Icon(Icons.image,
                              color: isDark
                                  ? MyColors.darkTextSecondary
                                  : Colors.grey,
                              size: 40.r),
                    ),
            ),
            // Title
            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Text(
                title,
                style: MyTextStyle.textMatn12Bold.copyWith(
                  color:
                      isDark ? MyColors.darkTextPrimary : MyColors.textMatn2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
