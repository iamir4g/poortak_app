import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class DateSeparator extends StatelessWidget {
  final String date;

  const DateSeparator({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.5.w, vertical: 8.h),
      child: Text(
        date,
        textAlign: TextAlign.center,
        style: MyTextStyle.textMatn13.copyWith(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? MyColors.darkTextPrimary : MyColors.textMatn2,
        ),
      ),
    ));
  }
}
