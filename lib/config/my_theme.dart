import 'package:flutter/material.dart';
import 'myColors.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: "IranSans",
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: MyColors.darkTextPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: "IranSans",
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: MyColors.darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: "IranSans",
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: MyColors.darkTextPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: "IranSans",
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: MyColors.darkTextSecondary,
      ),
      labelSmall: TextStyle(
        color: MyColors.text4,
        fontSize: 10,
        fontFamily: 'IranSans',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: MyColors.text4,
        fontSize: 10,
        fontFamily: 'IranSans',
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: MyColors.textMatn2,
        fontSize: 17,
        fontFamily: 'IranSans',
        fontWeight: FontWeight.w700,
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
      background: MyColors.darkBackground,
      error: MyColors.darkError,
      onPrimary: MyColors.darkTextPrimary,
      onSecondary: MyColors.darkTextPrimary,
      onSurface: MyColors.darkTextPrimary,
      onBackground: MyColors.darkTextPrimary,
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
  );

  static final lightTheme = ThemeData(
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: "IranSans",
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: MyColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: "IranSans",
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: MyColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: "IranSans",
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: MyColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: "IranSans",
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: MyColors.textSecondary,
      ),
      labelSmall: TextStyle(
        color: MyColors.text4,
        fontSize: 10,
        fontFamily: 'IranSans',
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: MyColors.text4,
        fontSize: 10,
        fontFamily: 'IranSans',
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: MyColors.textMatn2,
        fontSize: 17,
        fontFamily: 'IranSans',
        fontWeight: FontWeight.w700,
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
      background: MyColors.background,
      error: MyColors.error,
      onPrimary: MyColors.textLight,
      onSecondary: MyColors.textLight,
      onSurface: MyColors.textPrimary,
      onBackground: MyColors.textPrimary,
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
  );
}
