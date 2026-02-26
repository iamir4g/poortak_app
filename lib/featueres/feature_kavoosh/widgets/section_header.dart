import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 8.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: MyTextStyle.textMatn16Bold.copyWith(
                color: MyColors.textMatn2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: onSeeAllTap,
            child: Text(
              'همه',
              style: MyTextStyle.textMatn12Bold.copyWith(
                color: MyColors.text3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
