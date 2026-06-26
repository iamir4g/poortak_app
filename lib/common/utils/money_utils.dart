import 'package:persian_tools/persian_tools.dart';
import 'package:poortak/common/utils/digit_utils.dart';

class MoneyUtils {
  MoneyUtils._();

  static int parseRial(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    final raw = value.toString().trim();
    if (raw.isEmpty) return 0;
    final normalized = raw.replaceAll(',', '').replaceAll(' ', '');
    return int.tryParse(normalized) ?? 0;
  }

  static int rialToTomanInt(int rial) {
    if (rial == 0) return 0;
    return rial ~/ 10;
  }

  static int parseRialToTomanInt(dynamic value) {
    return rialToTomanInt(parseRial(value));
  }

  static String formatTomanFromRial(dynamic value) {
    final toman = parseRialToTomanInt(value);
    return formatTomanDisplay(toman);
  }

  static String formatTomanDisplay(int toman) {
    return toPersianDigits(toman.toString().addComma);
  }
}

