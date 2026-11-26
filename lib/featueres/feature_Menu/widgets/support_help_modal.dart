import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';
import 'package:poortak/common/utils/svg_embedded_png.dart';
import 'package:poortak/common/utils/url_launcher_utils.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/env.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SupportHelpModal extends StatelessWidget {
  const SupportHelpModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SupportHelpModal(),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final launched = await launchExternalUri(Uri.parse(url));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('امکان باز کردن لینک وجود ندارد'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final modalBackground = isDark
            ? MyColors.darkCardBackground
            : MyColors.supportModalBackground;
        final titleColor =
            isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;
        final subtitleColor =
            isDark ? MyColors.darkTextSecondary : MyColors.text3;
        final hoursBackground =
            isDark ? MyColors.darkBackground : MyColors.supportHoursBackground;
        final hoursTextColor =
            isDark ? MyColors.darkTextSecondary : MyColors.text2;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: Dimens.supportModalWidth,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: modalBackground,
              borderRadius: BorderRadius.circular(Dimens.supportCardRadius / 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text('نیاز به راهنمایی دارید؟',
                        style: MyTextStyle.textMatn20Bold),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        size: 24.sp,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'اگر سوالی دارید یا به مشکلی برخوردید، از طریق پیام‌رسان دلخواهتون به ما پیام بدید.',
                  style: MyTextStyle.textMatn12W300.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 20.h),
                _SupportChannelCard(
                  iconAsset: 'assets/images/support/bale_icon.svg',
                  title: 'پشتیبانی بله',
                  backgroundColor: MyColors.supportBaleBackground,
                  textColor: MyColors.supportBaleText,
                  onTap: () => _openLink(context, Env.supportBaleUrl),
                ),
                SizedBox(height: 12.h),
                _SupportChannelCard(
                  iconAsset: 'assets/images/support/telegram_icon.svg',
                  title: 'پشتیبانی تلگرام',
                  backgroundColor: MyColors.supportTelegramBackground,
                  textColor: MyColors.supportTelegramText,
                  onTap: () => _openLink(context, Env.supportTelegramUrl),
                ),
                SizedBox(height: 12.h),
                _SupportChannelCard(
                  iconAsset: 'assets/images/support/whatsapp_icon.svg',
                  title: 'پشتیبانی واتسپ',
                  backgroundColor: MyColors.supportWhatsappBackground,
                  textColor: MyColors.supportWhatsappText,
                  onTap: () => _openLink(context, Env.supportWhatsappUrl),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  height: Dimens.supportHoursHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hoursBackground,
                    borderRadius:
                        BorderRadius.circular(Dimens.supportHoursRadius),
                    border: Border.all(
                      color: MyColors.supportHoursBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'پاسخگویی همه‌روزه از ساعت ۱۰ الی ۱۶',
                    style: MyTextStyle.textMatn12W300.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: hoursTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SupportChannelCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SupportChannelCard({
    required this.iconAsset,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimens.supportCardWidth,
        height: Dimens.supportCardHeight,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(Dimens.supportCardRadius),
        ),
        child: Row(
          children: [
            Container(
              width: Dimens.supportCardIconSize,
              height: Dimens.supportCardIconSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: buildImageFromAssetOrEmbeddedSvg(iconAsset,
                  width: Dimens.supportCardLogoSize,
                  height: Dimens.supportCardLogoSize),
              //  SvgPicture.asset(
              //   iconAsset,
              //   width: Dimens.supportCardLogoSize,
              //   height: Dimens.supportCardLogoSize,
              // ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: MyTextStyle.textMatn14Bold.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 28.sp,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}
