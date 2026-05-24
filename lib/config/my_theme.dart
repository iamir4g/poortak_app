import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'myColors.dart';

@immutable
class LoginTheme extends ThemeExtension<LoginTheme> {
  final Color backgroundOverlayColor;
  final Color inputBackgroundColor;
  final Color inputTextColor;
  final Color iconColor;
  final Color iconContainerColor;
  final Color titleTextColor;
  final Color secondaryTextColor;
  final Color actionTextColor;
  final Color buttonTextColor;

  const LoginTheme({
    required this.backgroundOverlayColor,
    required this.inputBackgroundColor,
    required this.inputTextColor,
    required this.iconColor,
    required this.iconContainerColor,
    required this.titleTextColor,
    required this.secondaryTextColor,
    required this.actionTextColor,
    required this.buttonTextColor,
  });

  static const light = LoginTheme(
    backgroundOverlayColor: Colors.transparent,
    inputBackgroundColor: Colors.white,
    inputTextColor: MyColors.textMatn1,
    iconColor: MyColors.text4,
    iconContainerColor: Color(0xFFF6F6F6),
    titleTextColor: MyColors.textMatn1,
    secondaryTextColor: MyColors.text3,
    actionTextColor: MyColors.primary,
    buttonTextColor: Colors.white,
  );

  static const dark = LoginTheme(
    backgroundOverlayColor: MyColors.loginBackgroundOverlayDark,
    inputBackgroundColor: MyColors.loginInputBackgroundDark,
    inputTextColor: MyColors.loginTextPrimaryDark,
    iconColor: MyColors.loginIconColorDark,
    iconContainerColor: MyColors.loginIconContainerDark,
    titleTextColor: MyColors.loginTextPrimaryDark,
    secondaryTextColor: MyColors.loginTextPrimaryDark,
    actionTextColor: MyColors.loginTextPrimaryDark,
    buttonTextColor: MyColors.loginButtonText,
  );

  @override
  LoginTheme copyWith({
    Color? backgroundOverlayColor,
    Color? inputBackgroundColor,
    Color? inputTextColor,
    Color? iconColor,
    Color? iconContainerColor,
    Color? titleTextColor,
    Color? secondaryTextColor,
    Color? actionTextColor,
    Color? buttonTextColor,
  }) {
    return LoginTheme(
      backgroundOverlayColor:
          backgroundOverlayColor ?? this.backgroundOverlayColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputTextColor: inputTextColor ?? this.inputTextColor,
      iconColor: iconColor ?? this.iconColor,
      iconContainerColor: iconContainerColor ?? this.iconContainerColor,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      actionTextColor: actionTextColor ?? this.actionTextColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
    );
  }

  @override
  LoginTheme lerp(ThemeExtension<LoginTheme>? other, double t) {
    if (other is! LoginTheme) return this;
    return LoginTheme(
      backgroundOverlayColor:
          Color.lerp(backgroundOverlayColor, other.backgroundOverlayColor, t) ??
              backgroundOverlayColor,
      inputBackgroundColor:
          Color.lerp(inputBackgroundColor, other.inputBackgroundColor, t) ??
              inputBackgroundColor,
      inputTextColor:
          Color.lerp(inputTextColor, other.inputTextColor, t) ?? inputTextColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      iconContainerColor:
          Color.lerp(iconContainerColor, other.iconContainerColor, t) ??
              iconContainerColor,
      titleTextColor:
          Color.lerp(titleTextColor, other.titleTextColor, t) ?? titleTextColor,
      secondaryTextColor:
          Color.lerp(secondaryTextColor, other.secondaryTextColor, t) ??
              secondaryTextColor,
      actionTextColor: Color.lerp(actionTextColor, other.actionTextColor, t) ??
          actionTextColor,
      buttonTextColor: Color.lerp(buttonTextColor, other.buttonTextColor, t) ??
          buttonTextColor,
    );
  }
}

@immutable
class TermsConditionsTheme extends ThemeExtension<TermsConditionsTheme> {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color dividerColor;

  const TermsConditionsTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.dividerColor,
  });

  static const light = TermsConditionsTheme(
    backgroundColor: Colors.white,
    textColor: MyColors.textMatn1,
    iconColor: Colors.black,
    dividerColor: MyColors.divider,
  );

  static const dark = TermsConditionsTheme(
    backgroundColor: MyColors.termsBackgroundDark,
    textColor: MyColors.loginTextPrimaryDark,
    iconColor: MyColors.loginTextPrimaryDark,
    dividerColor: MyColors.loginIconContainerDark,
  );

  @override
  TermsConditionsTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    Color? dividerColor,
  }) {
    return TermsConditionsTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  TermsConditionsTheme lerp(
      ThemeExtension<TermsConditionsTheme>? other, double t) {
    if (other is! TermsConditionsTheme) return this;
    return TermsConditionsTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      textColor: Color.lerp(textColor, other.textColor, t) ?? textColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      dividerColor:
          Color.lerp(dividerColor, other.dividerColor, t) ?? dividerColor,
    );
  }
}

class MyThemes {
  static ThemeData get darkTheme => ThemeData(
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: "IranSans",
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: MyColors.darkTextPrimary,
          ),
          titleMedium: TextStyle(
            fontFamily: "IranSans",
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: MyColors.darkTextPrimary,
          ),
          bodyMedium: TextStyle(
            fontFamily: "IranSans",
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: MyColors.darkTextPrimary,
          ),
          bodySmall: TextStyle(
            fontFamily: "IranSans",
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: MyColors.darkTextSecondary,
          ),
          labelSmall: TextStyle(
            color: MyColors.text4,
            fontSize: 10.sp,
            fontFamily: 'IranSans',
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            color: MyColors.text4,
            fontSize: 10.sp,
            fontFamily: 'IranSans',
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            color: MyColors.textMatn2,
            fontSize: 17.sp,
            fontFamily: 'IranSans',
            fontWeight: FontWeight.w700,
          ),
          displaySmall: TextStyle(
            color: MyColors.darkText1,
            fontSize: 13.sp,
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w500,
          ),
          headlineSmall: TextStyle(
            color: MyColors.darkTextSecondary,
            fontSize: 10.sp,
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w300,
          ),
        ),
        primaryColor: MyColors.primary,
        scaffoldBackgroundColor: MyColors.darkBackground,
        cardColor: MyColors.darkCardBackground,
        dividerColor: MyColors.darkBorder,
        colorScheme: const ColorScheme.dark(
          primary: MyColors.primary,
          secondary: MyColors.secondary,
          surface: MyColors.darkCardBackground,
          error: MyColors.darkError,
          onPrimary: MyColors.darkTextPrimary,
          onSecondary: MyColors.darkTextPrimary,
          onSurface: MyColors.darkTextPrimary,
          onError: MyColors.darkTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: MyColors.darkBackground,
          foregroundColor: MyColors.darkTextPrimary,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: MyColors.darkCardBackground,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.primary,
            foregroundColor: MyColors.darkTextPrimary,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MyColors.darkTextAccent,
          ),
        ),
        extensions: const <ThemeExtension<dynamic>>[
          LoginTheme.dark,
          TermsConditionsTheme.dark,
        ],
      );

  static ThemeData get lightTheme => ThemeData(
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: "IranSans",
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: MyColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontFamily: "IranSans",
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: MyColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontFamily: "IranSans",
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: MyColors.textPrimary,
          ),
          bodySmall: TextStyle(
            fontFamily: "IranSans",
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: MyColors.textSecondary,
          ),
          labelSmall: TextStyle(
            color: MyColors.text4,
            fontSize: 10.sp,
            fontFamily: 'IranSans',
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            color: MyColors.text4,
            fontSize: 10.sp,
            fontFamily: 'IranSans',
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            color: MyColors.textMatn2,
            fontSize: 17.sp,
            fontFamily: 'IranSans',
            fontWeight: FontWeight.w700,
          ),
          displaySmall: TextStyle(
            color: MyColors.text1,
            fontSize: 13.sp,
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w500,
          ),
          headlineSmall: TextStyle(
            color: MyColors.text2,
            fontSize: 10.sp,
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w300,
          ),
        ),
        primaryColor: MyColors.primary,
        scaffoldBackgroundColor: MyColors.background,
        cardColor: MyColors.cardBackground,
        dividerColor: MyColors.divider,
        colorScheme: const ColorScheme.light(
          primary: MyColors.primary,
          secondary: MyColors.secondary,
          surface: MyColors.cardBackground,
          error: MyColors.error,
          onPrimary: MyColors.textLight,
          onSecondary: MyColors.textLight,
          onSurface: MyColors.textPrimary,
          onError: MyColors.textLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: MyColors.background,
          foregroundColor: MyColors.textPrimary,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: MyColors.cardBackground,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.primary,
            foregroundColor: MyColors.textLight,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MyColors.primary,
          ),
        ),
        extensions: const <ThemeExtension<dynamic>>[
          LoginTheme.light,
          TermsConditionsTheme.light,
        ],
      );
}
