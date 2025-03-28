import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

class CustomTextStyle {
  static const TextStyle titleLesonText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: MyColors.text4,
  );
  static const TextStyle subTitleLeasonText =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

  static const TextStyle lessonTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle lessonNumber = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}
