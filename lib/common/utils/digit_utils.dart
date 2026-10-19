import 'package:flutter/services.dart';

final RegExp _persianScript = RegExp(
  r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
);

bool hasPersianScript(String text) => _persianScript.hasMatch(text);

/// Converts digits to Persian when [input] contains Persian/Arabic script,
/// otherwise converts them to English (Latin) digits.
String localizeDigits(String input) {
  if (hasPersianScript(input)) return toPersianDigits(input);
  return toEnglishDigits(input);
}

String toEnglishDigits(String input) {
  return input
      .replaceAll('۰', '0')
      .replaceAll('۱', '1')
      .replaceAll('۲', '2')
      .replaceAll('۳', '3')
      .replaceAll('۴', '4')
      .replaceAll('۵', '5')
      .replaceAll('۶', '6')
      .replaceAll('۷', '7')
      .replaceAll('۸', '8')
      .replaceAll('۹', '9')
      .replaceAll('٠', '0')
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9');
}

String toPersianDigits(String input) {
  final english = toEnglishDigits(input);
  return english
      .replaceAll('0', '۰')
      .replaceAll('1', '۱')
      .replaceAll('2', '۲')
      .replaceAll('3', '۳')
      .replaceAll('4', '۴')
      .replaceAll('5', '۵')
      .replaceAll('6', '۶')
      .replaceAll('7', '۷')
      .replaceAll('8', '۸')
      .replaceAll('9', '۹');
}

String normalizeOtpForServer(String input, {int maxLength = 4}) {
  final digits = toEnglishDigits(input).replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length <= maxLength ? digits : digits.substring(0, maxLength);
}

String formatTomanAmount(String amount) {
  try {
    final rialAmount = double.parse(toEnglishDigits(amount));
    final tomanAmount = (rialAmount / 10).floor();
    final formattedAmount = tomanAmount.toStringAsFixed(0);
    return '${toPersianDigits(formattedAmount)} تومان';
  } catch (_) {
    return '${toPersianDigits(amount)} تومان';
  }
}

class PersianOtpTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  PersianOtpTextInputFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final english = toEnglishDigits(newValue.text);
    final digitsOnly = english.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digitsOnly.length <= maxLength
        ? digitsOnly
        : digitsOnly.substring(0, maxLength);
    final persian = toPersianDigits(limited);

    return TextEditingValue(
      text: persian,
      selection: TextSelection.collapsed(offset: persian.length),
    );
  }
}
