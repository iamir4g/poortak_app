import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';

class FontSizeHelper {
  /// محاسبه اندازه فونت بر اساس تنظیمات کاربر
  /// [baseFontSize] اندازه فونت پایه
  /// [context] context برای دسترسی به SettingsCubit
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final settingsState = context.read<SettingsCubit>().state;
    
    // محاسبه ضریب مقیاس: حداقل 0.8 و حداکثر 1.4 برابر اندازه اصلی
    double scaleFactor = 0.8 + (settingsState.textSize * 0.6);
    
    return baseFontSize * scaleFactor;
  }

  /// ایجاد TextStyle با اندازه فونت تطبیقی
  /// [context] context برای دسترسی به SettingsCubit
  /// [baseFontSize] اندازه فونت پایه
  /// [color] رنگ متن (اختیاری)
  /// [fontWeight] وزن فونت (اختیاری)
  /// [fontStyle] استایل فونت (اختیاری)
  static TextStyle getScaledTextStyle(
    BuildContext context,
    double baseFontSize, {
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontSize: getScaledFontSize(context, baseFontSize),
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  /// ایجاد TextStyle با اندازه فونت تطبیقی برای متن‌های محتوای درسی
  /// این متد مخصوص متن‌های محتوای درسی است که باید از تنظیمات فونت استفاده کنند
  static TextStyle getContentTextStyle(
    BuildContext context, {
    double baseFontSize = 16.0,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return getScaledTextStyle(
      context,
      baseFontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
}
