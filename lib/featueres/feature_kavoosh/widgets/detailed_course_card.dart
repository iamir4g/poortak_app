import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/video_detail_screen.dart';

class DetailedCourseCard extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final bool isPurchased;
  final String? imagePath;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const DetailedCourseCard({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    this.isPurchased = false,
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
        margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
        constraints: BoxConstraints(minHeight: 140.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
            // Image Container
            Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Container(
                width: 100.w,
                height: 116.h,
                decoration: BoxDecoration(
                  color: backgroundColor ?? MyColors.background1,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 40.r),
                      ),
              ),
            ),

            // Text Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 8.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      style: MyTextStyle.textMatn16Bold.copyWith(
                        color: MyColors.textMatn2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    
                    // Author
                    Text(
                      author,
                      style: MyTextStyle.textMatn12W500.copyWith(
                        color: MyColors.text3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Bottom Row: Date and Purchased Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.r,
                                color: MyColors.text4,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  date,
                                  style: MyTextStyle.textMatn10W300.copyWith(
                                    color: MyColors.text4,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (isPurchased)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: MyColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'خریداری شده',
                                  style: MyTextStyle.textMatn10W300.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.success,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.check_circle,
                                  size: 14.r,
                                  color: MyColors.success,
                                ),
                              ],
                            ),
                          ),
                      ],
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
