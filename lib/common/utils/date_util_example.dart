import 'package:poortak/common/utils/date_util.dart';

/// Example usage of DateUtil class
class DateUtilExample {
  static void demonstrateUsage() {
    final now = DateTime.now();

    // Convert DateTime to Persian month-year format
    final monthYear = DateUtil.toPersianMonthYear(now);
    print('Month-Year: $monthYear'); // Output: "مهر ۱۴۰۴"

    // Convert DateTime to Persian date string
    final persianDate = DateUtil.toPersianDateString(now);
    print('Persian Date: $persianDate'); // Output: "۱۴۰۴-۰۷-۰۱"

    // Convert Persian date string to DateTime
    final dateTime = DateUtil.fromPersianDateString('۱۴۰۴-۰۷-۰۱');
    print('DateTime: $dateTime');

    // Convert Persian month-year to DateTime
    final dateTimeFromMonthYear = DateUtil.fromPersianMonthYear('مهر ۱۴۰۴');
    print('DateTime from Month-Year: $dateTimeFromMonthYear');

    // Get current Persian date
    final currentPersianDate = DateUtil.getCurrentPersianDate();
    print('Current Persian Date: $currentPersianDate');

    // Get current Persian month-year
    final currentMonthYear = DateUtil.getCurrentPersianMonthYear();
    print('Current Month-Year: $currentMonthYear');

    // Format with custom separator
    final formattedDate = DateUtil.formatPersianDate(now, '/');
    print('Formatted Date: $formattedDate'); // Output: "۱۴۰۴/۰۷/۰۱"

    // Get Persian day name
    final dayName = DateUtil.getPersianDayName(now);
    print('Day Name: $dayName'); // Output: "شنبه"

    // Convert English digits to Persian
    final persianDigits = DateUtil.convertEnglishToPersianDigits('1404-07-01');
    print('Persian Digits: $persianDigits'); // Output: "۱۴۰۴-۰۷-۰۱"
  }
}
