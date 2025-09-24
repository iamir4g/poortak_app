 import 'package:flutter/material.dart';
import 'myColors.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    textTheme: const TextTheme(
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
      titleMedium: TextStyle(
          fontFamily: "IranSans", fontSize: 20, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(
          fontFamily: "IranSans", fontSize: 15, fontWeight: FontWeight.w400),
    ),
    // highlightColor: Colors.indigo,
    // backgroundColor: Colors.black,
    // unselectedWidgetColor: Colors.black,
    // primaryColorLight: Color.fromRGBO(252, 178, 98, 1),
    // scaffoldBackgroundColor: Colors.white,
    // primaryColor: Colors.amber.shade800,
    // indicatorColor: Colors.amber,
    // secondaryHeaderColor: Color.fromRGBO(176, 106, 2, 1),
    // iconTheme: IconThemeData(color: Colors.amber.shade800),
    //
    // // colorScheme: const ColorScheme.light()
  );
}
