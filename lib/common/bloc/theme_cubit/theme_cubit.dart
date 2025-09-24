import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poortak/locator.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences _prefs = locator<SharedPreferences>();

  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.light)) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = _prefs.getBool('isDarkMode') ?? false;
    emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  void toggleTheme() {
    final newThemeMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    _prefs.setBool('isDarkMode', newThemeMode == ThemeMode.dark);
    emit(ThemeState(themeMode: newThemeMode));
  }

  void setTheme(ThemeMode themeMode) {
    _prefs.setBool('isDarkMode', themeMode == ThemeMode.dark);
    emit(ThemeState(themeMode: themeMode));
  }
}

