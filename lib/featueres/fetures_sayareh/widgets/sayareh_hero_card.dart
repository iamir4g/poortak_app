import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/locator.dart';

class SayarehHeroCard extends StatefulWidget {
  final String? lessonTitle;
  final double overallProgress;
  final VoidCallback? onContinueTap;

  const SayarehHeroCard({
    super.key,
    this.lessonTitle,
    this.overallProgress = 0,
    this.onContinueTap,
  });

  @override
  State<SayarehHeroCard> createState() => _SayarehHeroCardState();
}

class _SayarehHeroCardState extends State<SayarehHeroCard> {
  String _firstName = 'دوست';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await locator<PrefsOperator>().getUserFirstName();
    if (!mounted) return;
    setState(() {
      _firstName = (name != null && name.trim().isNotEmpty) ? name.trim() : 'دوست';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lessonLabel = widget.lessonTitle?.trim().isNotEmpty == true
        ? widget.lessonTitle!.trim()
        : 'درس اول';
    final progress = widget.overallProgress.clamp(0, 100).toInt();

    return Container(
      width: double.infinity,
      height: 216.h,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        gradient: isDark ? null : MyColors.sayarehHomeHeroGradient,
        color: isDark ? MyColors.darkCardBackground : null,
        borderRadius: BorderRadius.circular(24.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: -20.w,
            top: -10.h,
            child: Image.asset(
              'assets/images/sayareh_home/hero_splash.png',
              width: 180.w,
              height: 190.h,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: -30.w,
            bottom: -20.h,
            child: Image.asset(
              'assets/images/sayareh_home/hero_character.png',
              width: 220.w,
              height: 200.h,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 16.w,
            top: 28.h,
            left: 150.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'سلام $_firstName! 👋',
                  textAlign: TextAlign.right,
                  style: MyTextStyle.sayarehHomeGreeting.copyWith(
                    color: isDark
                        ? MyColors.darkTextAccent
                        : MyColors.sayarehHomePurple,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'امروز آماده ای؟',
                  textAlign: TextAlign.right,
                  style: MyTextStyle.sayarehHomeHeroTitle.copyWith(
                    color: isDark ? MyColors.darkTextPrimary : MyColors.text1,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'بیا ادامه $lessonLabel رو با هم تمام کنیم.',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MyTextStyle.sayarehHomeHeroSubtitle.copyWith(
                    color:
                        isDark ? MyColors.darkTextSecondary : MyColors.text3,
                  ),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onContinueTap,
                      borderRadius: BorderRadius.circular(30.r),
                      child: Container(
                        width: 158.w,
                        height: 42.h,
                        decoration: BoxDecoration(
                          gradient: MyColors.sayarehHomeCtaGradient,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ادامه $lessonLabel',
                              style: MyTextStyle.sayarehHomeCtaText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: 6.w),
                            SvgPicture.asset(
                              'assets/images/sayareh_home/play_icon.svg',
                              width: 14.r,
                              height: 14.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 14.w,
            bottom: 12.h,
            child: Container(
              width: 150.w,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark
                    ? MyColors.darkBackgroundSecondary
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'پیشرفت کلی دوره',
                    style: MyTextStyle.textMatn10W300.copyWith(
                      color: isDark
                          ? MyColors.darkTextSecondary
                          : MyColors.text3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        '$progress%',
                        textDirection: TextDirection.ltr,
                        style: MyTextStyle.textProgressBar.copyWith(
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 6.h,
                            backgroundColor: MyColors.progressBarBackground,
                            color: MyColors.progressBarColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
