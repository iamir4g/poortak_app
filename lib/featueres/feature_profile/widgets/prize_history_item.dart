import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class PrizeHistoryItem extends StatelessWidget {
  final String title;
  final String points;
  final bool isCompleted;

  const PrizeHistoryItem({
    super.key,
    required this.title,
    required this.points,
    this.isCompleted = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
        width: 360.w,
        height: 68.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDarkMode
              ? MyColors.darkCardBackground
              : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            children: [
              // Check icon
              SizedBox(
                width: 25.w,
                height: 25.h,
                child: isCompleted
                    ? Image.asset(
                        'assets/images/check_icon.png',
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        Icons.pending,
                        color: isDarkMode
                            ? MyColors.darkTextSecondary
                            : MyColors.textSecondary,
                        size: 20.sp,
                      ),
              ),

              // Title
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 16.w),
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: MyTextStyle.textMatn13.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : MyColors.textMatn2,
                    ),
                  ),
                ),
              ),
              // Points amount
              Container(
                margin: EdgeInsets.only(left: 16.w),
                child: Text(
                  points,
                  style: MyTextStyle.textMatn16.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? MyColors.darkTextPrimary
                        : MyColors.textMatn2,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
