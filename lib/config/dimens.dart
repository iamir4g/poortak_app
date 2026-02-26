import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dimens {
  Dimens._();

  // Responsive helpers: scale down on small screens, keep fixed on large screens
  static double nw(double size) => size.w > size ? size : size.w;
  static double nh(double size) => size.h > size ? size : size.h;
  static double nsp(double size) => size.sp > size ? size : size.sp;
  static double nr(double size) => size.r > size ? size : size.r;

  // Spacing & Padding
  static double get tiny => nw(4.0);
  static double get small => nw(8.0);
  static double get medium => nw(16.0);
  static double get large => nw(24.0);
  static double get xLarge => nw(32.0);
  static double get xxLarge => nw(48.0);

  // Radius
  static double get radiusSmall => nr(8.0);
  static double get radiusMedium => nr(12.0);
  static double get radiusLarge => nr(16.0);
  static double get radiusXLarge => nr(24.0);
  static double get radiusCircle => nr(100.0);

  // Icons
  static double get iconSmall => nw(16.0);
  static double get iconMedium => nw(24.0);
  static double get iconLarge => nw(32.0);
  static double get iconXLarge => nw(48.0);

  // Buttons
  static double get buttonHeight => nh(48.0);
  static double get buttonSmallHeight => nh(36.0);

  // Specific
  static double get cardElevation => nr(4.0);
  static double get dividerHeight => nh(1.0);
  static double get bottomNavHeight => nh(60.0);
}
