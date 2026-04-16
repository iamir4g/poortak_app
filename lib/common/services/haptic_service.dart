import 'package:flutter/services.dart';

class HapticService {
  HapticService._();

  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> wrongAnswerFeedback() async {
    await HapticFeedback.lightImpact();
  }
}
