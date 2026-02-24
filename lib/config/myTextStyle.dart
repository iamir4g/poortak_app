import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';

class MyTextStyle {
  static TextStyle get bottomNavEnabledTextStyle => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.primary,
      );

  static TextStyle get textHeader16Bold => TextStyle(
        fontFamily: "IranSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textMatn1,
      );
  static TextStyle get text14Wrong => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.lineThrough,
        color: MyColors.error,
      );
  static TextStyle get text24Correct => TextStyle(
        fontFamily: "IranSans",
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.success,
      );
  static TextStyle get textMatn16 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn16Bold => TextStyle(
        fontFamily: "IranSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn14Bold => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn18Bold => TextStyle(
        fontFamily: "IranSans",
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn17W700 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn12W700 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn12Bold => TextStyle(
        fontFamily: "IranSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn12W500 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn12W300 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn10W300 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 10.sp,
        fontWeight: FontWeight.normal,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn15 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textMatn1,
      );

  static TextStyle get textMatn13 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 13.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatn9 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 9.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.textMatn1,
      );
  static TextStyle get textMatnBtn => TextStyle(
        color: MyColors.textLight,
        fontSize: 16.sp,
        fontFamily: "IranSans",
        fontWeight: FontWeight.bold,
      );
  static TextStyle get textMatn13PrimaryShade1 => TextStyle(
      fontFamily: "IranSans",
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: MyColors.primaryShade1);

  static TextStyle get textCenter16 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.textMatn1,
      );

  static TextStyle get textMatn11 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 11.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.textMatn1,
      );

  static TextStyle get textProgressBar => TextStyle(
        color: MyColors.progressBarColor,
        fontWeight: FontWeight.w700,
        fontSize: 12.sp,
      );

  static TextStyle get tabLabel16 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.textMatn1,
      );

  // static const TextStyle bottomNavDisabledTextStyle = TextStyle(
  //   fontFamily: "IranSans",
  //   fontSize: 14,
  //   fontWeight: FontWeight.w400,
  //   color: MyColors.primary,
  // );
  static TextStyle get textHint => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp, // Added default size for hint
        color: MyColors.textHint,
      );

  static TextStyle get textCancelButton => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.textCancelButton,
      );
}
