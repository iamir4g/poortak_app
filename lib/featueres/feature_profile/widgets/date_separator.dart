import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16.5, vertical: 8),
      child: Text(
        date,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'IranSans',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? MyColors.darkTextPrimary : MyColors.textMatn2,
        ),
      ),
    ));
  }
}
