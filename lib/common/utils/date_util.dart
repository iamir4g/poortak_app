import 'package:shamsi_date/shamsi_date.dart';

class DateUtil {
  // Persian month names
  static const List<String> persianMonths = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند'
  ];

  /// Convert DateTime to Persian month-year format (e.g., "مهر ۱۴۰۴")
  static String toPersianMonthYear(DateTime dateTime) {
    final shamsiDate = Jalali.fromDateTime(dateTime);
    final month = persianMonths[shamsiDate.month - 1];
    return '$month ${shamsiDate.year}';
  }

  /// Convert DateTime to Persian date format (e.g., "۱۴۰۴-۰۷-۰۱")
  static String toPersianDateString(DateTime dateTime) {
    final shamsiDate = Jalali.fromDateTime(dateTime);
    final year = shamsiDate.year.toString();
    final month = shamsiDate.month.toString().padLeft(2, '0');
    final day = shamsiDate.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Convert Persian date string to DateTime
  /// Input format: "۱۴۰۴-۰۷-۰۱" or "1404-07-01"
  static DateTime fromPersianDateString(String persianDateString) {
    // Remove any Persian digits and replace with English digits
    final cleanDate = _convertPersianToEnglishDigits(persianDateString);
    final parts = cleanDate.split('-');

    if (parts.length != 3) {
      throw FormatException('Invalid date format. Expected: YYYY-MM-DD');
    }

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    final jalaliDate = Jalali(year, month, day);
    return jalaliDate.toDateTime();
  }

  /// Convert Persian month-year string to DateTime (first day of the month)
  /// Input format: "مهر ۱۴۰۴"
  static DateTime fromPersianMonthYear(String monthYearString) {
    final parts = monthYearString.trim().split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid month-year format. Expected: "مهر ۱۴۰۴"');
    }

    final monthName = parts[0];
    final yearString = _convertPersianToEnglishDigits(parts[1]);
    final year = int.parse(yearString);

    final monthIndex = persianMonths.indexOf(monthName);
    if (monthIndex == -1) {
      throw FormatException('Invalid month name: $monthName');
    }

    final jalaliDate = Jalali(year, monthIndex + 1, 1);
    return jalaliDate.toDateTime();
  }

  /// Get current Persian date as string
  static String getCurrentPersianDate() {
    return toPersianDateString(DateTime.now());
  }

  /// Get current Persian month-year
  static String getCurrentPersianMonthYear() {
    return toPersianMonthYear(DateTime.now());
  }

  /// Convert Persian digits to English digits
  static String _convertPersianToEnglishDigits(String input) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < persianDigits.length; i++) {
      result = result.replaceAll(persianDigits[i], englishDigits[i]);
    }
    return result;
  }

  /// Convert English digits to Persian digits
  static String convertEnglishToPersianDigits(String input) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    String result = input;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], persianDigits[i]);
    }
    return result;
  }

  /// Format Persian date with custom separator
  /// Example: formatPersianDate(DateTime.now(), '/') -> "۱۴۰۴/۰۷/۰۱"
  static String formatPersianDate(DateTime dateTime, String separator) {
    final shamsiDate = Jalali.fromDateTime(dateTime);
    final year = shamsiDate.year.toString();
    final month = shamsiDate.month.toString().padLeft(2, '0');
    final day = shamsiDate.day.toString().padLeft(2, '0');
    return '$year$separator$month$separator$day';
  }

  /// Get Persian day name
  static String getPersianDayName(DateTime dateTime) {
    final shamsiDate = Jalali.fromDateTime(dateTime);
    const dayNames = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه'
    ];
    return dayNames[shamsiDate.weekDay % 7];
  }

  /// Check if two dates are in the same Persian month
  static bool isSamePersianMonth(DateTime date1, DateTime date2) {
    final shamsi1 = Jalali.fromDateTime(date1);
    final shamsi2 = Jalali.fromDateTime(date2);
    return shamsi1.year == shamsi2.year && shamsi1.month == shamsi2.month;
  }

  /// Get Persian month name by index (1-12)
  static String getPersianMonthName(int monthIndex) {
    if (monthIndex < 1 || monthIndex > 12) {
      throw ArgumentError('Month index must be between 1 and 12');
    }
    return persianMonths[monthIndex - 1];
  }
}
