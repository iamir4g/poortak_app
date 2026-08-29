import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';

class MyTextStyle {
  static TextStyle get sayarehHeader12Bold => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
        height: 1.0,
        letterSpacing: 0.0,
        color: MyColors.text1,
      );

  static TextStyle get modalAction16MediumBlue => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        height: 1.0,
        letterSpacing: 0.0,
        color: MyColors.secondaryShade2,
      );

  static TextStyle get modalAction16MediumOnDark => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        height: 1.0,
        letterSpacing: 0.0,
        color: Colors.white,
      );

  static TextStyle get bottomNavEnabledTextStyle => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.primary,
      );

  static TextStyle get textHeader16Bold => TextStyle(
        fontFamily: "IRANSans",
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

  static TextStyle textMatn14BoldFor(BuildContext context) =>
      textMatn14Bold.copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? MyColors.darkTextPrimary
            : MyColors.textMatn1,
      );

  static TextStyle body16For(BuildContext context) => TextStyle(
        fontFamily: "IranSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.dark
            ? MyColors.darkTextPrimary
            : MyColors.textMatn1,
      );

  static TextStyle body14SecondaryFor(BuildContext context) => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.dark
            ? MyColors.darkTextSecondary
            : MyColors.text3,
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
  static TextStyle get textBadge10W700 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
        color: MyColors.background,
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
  static TextStyle get text10MediumText6 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.text6,
        height: 1.5,
        letterSpacing: 1.0,
      );

  static TextStyle get description10Medium => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        height: 1.5,
        letterSpacing: 0.0,
        color: MyColors.text6,
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
        fontFamily: "IRANSans",
        fontWeight: FontWeight.bold,
      );

  static TextStyle textMatnBtnFor(BuildContext context) => TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 16.sp,
        fontFamily: "IRANSans",
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

  static TextStyle get tabActiveTextStyle => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.activeTabBackground,
      );

  static TextStyle get tabInactiveTextStyle => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.inactiveTabBackground,
      );

  static TextStyle get text16MediumText1 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.text1,
        height: 1.0,
      );

  static TextStyle get text14LightText3 => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.text3,
        height: 1.0,
      );

  static TextStyle get referralCodeInput14Medium => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.textMatn1,
        height: 1.0,
      );

  static TextStyle referralCodeTitle14MediumFor(bool isDark) => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
        height: 1.0,
      );

  static TextStyle referralCodeHint14RegularFor(bool isDark) => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: isDark ? MyColors.darkTextSecondary : MyColors.text6,
        height: 1.0,
      );

  static TextStyle referralCodeValue14MediumFor(bool isDark) => TextStyle(
        fontFamily: "IranSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
        height: 1.0,
      );

  static TextStyle referralCodeButton12BoldFor(Color color) => TextStyle(
        fontFamily: "IranSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.0,
      );

  static TextStyle referralCodeFeedbackSuccess12MediumFor(bool isDark) =>
      TextStyle(
        fontFamily: "IranSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? MyColors.referralSuccessDark : MyColors.referralSuccessLight,
        height: 1.0,
      );

  static TextStyle referralCodeFeedbackError12MediumFor(bool isDark) =>
      TextStyle(
        fontFamily: "IranSans",
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? MyColors.referralErrorDark : MyColors.referralErrorLight,
        height: 1.0,
      );

  static TextStyle get paymentSecurityTitle13Medium => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.activeTabBackground,
        height: 1.0,
      );

  static TextStyle get paymentSecuritySubtitle10Medium => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: MyColors.activeTabBackground,
        height: 1.0,
      );

  static TextStyle get contactTitle18Light => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 18.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.activeTabBackground,
        height: 1.0,
        letterSpacing: 0.0,
      );

  static TextStyle get contactDescription15Light => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 15.sp,
        fontWeight: FontWeight.w300,
        color: MyColors.activeTabBackground,
        height: 1.0,
        letterSpacing: 0.0,
      );

  static TextStyle get paymentHistoryLabel14Light => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.normal,
        height: 1.0,
        letterSpacing: 0.0,
        color: MyColors.textMatn1,
      );

  static TextStyle get paymentHistoryValue14Medium => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        height: 1.0,
        letterSpacing: 0.0,
        color: MyColors.textMatn1,
      );

  static TextStyle get modalTitle18Medium => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        height: 1.0,
        letterSpacing: 0.0,
        color: MyColors.textMatn1,
      );

  static TextStyle get modalMessage14Medium => TextStyle(
        fontFamily: "IRANSans",
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        height: 1.0,
        letterSpacing: 0.0,
        color: MyColors.text3,
      );

  // Score guide (How to get points)
  static const String scoreGuideScreenTitle = 'روش های کسب امتیاز';
  static const String scoreGuideMembershipTitle = 'عضویت در اپلیکیشن';
  static const String scoreGuideMembershipPoints = '۵ سکه';
  static const String scoreGuideMembershipDescription =
      'با ثبت شماره تماس خود در اپلیکیشن ۵ سکه دریافت میکنید.';
  static const String scoreGuidePurchaseTitle = 'خرید از اپلیکیشن';
  static const String scoreGuidePurchasePoints = '۵ سکه';
  static const String scoreGuidePurchaseDescription =
      'با هر خرید از اپلیکیشن ۵ سکه دریافت میکنید.';
  static const String scoreGuidePackageTitle = 'خرید بسته کامل سیاره آی نو';
  static const String scoreGuidePackagePoints = '۵۰ سکه';
  static const String scoreGuidePackageDescription =
      'با خرید بسته ی کامل سیاره آی نو ۱۰ سکه دریافت میکنید.';
  static const String scoreGuideInviteTitle = 'دعوت از دوستان';
  static const String scoreGuideInvitePoints = '۱۰ سکه';
  static const String scoreGuideInviteDescription =
      'با ارائه کد معرف به دوستان خود با ورود هریک به اپلیکیشن و انجام خرید، هر کدام ۱۰ امتیاز به دست می آورید.';
  static const String scoreGuideInviteButton = 'دعوت از دوستان';

  static TextStyle scoreGuideAppBarTitleFor(bool isDark) => textMatn15.copyWith(
        color: MyColors.scoreGuideAppBarForeground(isDark),
      );

  static TextStyle scoreGuideCardTitleFor(bool isDark) => textMatn16.copyWith(
        fontWeight: FontWeight.w500,
        color: MyColors.scoreGuideTitleColor(isDark),
      );

  static TextStyle scoreGuideCardDescriptionFor(bool isDark) =>
      textMatn10W300.copyWith(
        color: MyColors.scoreGuideBodyColor(isDark),
        height: 1.4,
      );

  static TextStyle scoreGuidePointsBadgeFor(bool isDark) => textMatn16.copyWith(
        fontWeight: FontWeight.w500,
        color: MyColors.scoreGuidePointsBadgeTextColor(isDark),
      );

  static TextStyle scoreGuideInviteButtonFor(bool isDark) => textMatn15.copyWith(
        color: MyColors.textLight,
        fontWeight: FontWeight.w500,
      );
}
