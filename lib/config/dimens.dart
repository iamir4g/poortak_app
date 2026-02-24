import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dimens {
  Dimens._();

  // Spacing & Padding
  static double get tiny => 4.0.w;
  static double get small => 8.0.w;
  static double get medium => 16.0.w;
  static double get large => 24.0.w;
  static double get xLarge => 32.0.w;
  static double get xxLarge => 48.0.w;

  // Radius
  static double get radiusSmall => 8.0.r;
  static double get radiusMedium => 12.0.r;
  static double get radiusLarge => 16.0.r;
  static double get radiusXLarge => 24.0.r;
  static double get radiusCircle => 100.0.r;

  // Icons
  static double get iconSmall => 16.0.w;
  static double get iconMedium => 24.0.w;
  static double get iconLarge => 32.0.w;
  static double get iconXLarge => 48.0.w;

  // Buttons
  static double get buttonHeight => 48.0.h;
  static double get buttonSmallHeight => 36.0.h;

  // Specific
  static double get cardElevation => 4.0.r;
  static double get dividerHeight => 1.0.h;
  static double get bottomNavHeight => 60.0.h;
}
