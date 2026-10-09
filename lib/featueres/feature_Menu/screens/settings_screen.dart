import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = "/settings";
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? MyColors.darkBackground : MyColors.background;
    final primaryTextColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;
    final secondaryTextColor =
        isDark ? MyColors.darkTextSecondary : MyColors.textSecondary;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: PoortakAppBar(
            title: 'تنظیمات',
            centerTitle: true,
            foregroundColor: primaryTextColor,
            titleStyle: MyTextStyle.textHeader16Bold.copyWith(fontSize: 20.sp),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                // Settings Sections
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),

                        // Display Settings
                        _buildSettingsSection(
                          title: "تنظیمات نمایش",
                          icon: Icons.monitor,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          children: [
                            _buildToggleOption(
                              title: "نمایش اپلیکیشن به صورت تمام صفحه",
                              primaryTextColor: primaryTextColor,
                              value: state.fullScreenMode,
                              onChanged: (value) {
                                context
                                    .read<SettingsCubit>()
                                    .updateFullScreenMode(value);
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // App Notifications
                        _buildSettingsSection(
                          title: "اعلانات برنامه",
                          icon: Icons.notifications,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          children: [
                            _buildToggleOption(
                              title: "دریافت اعلان هنگام دستاورد جدید",
                              primaryTextColor: primaryTextColor,
                              value: false,
                              onChanged: (_) {},
                              comingSoon: true,
                            ),
                            _buildToggleOption(
                              title: "دریافت اعلان های عمومی",
                              primaryTextColor: primaryTextColor,
                              value: false,
                              onChanged: (_) {},
                              comingSoon: true,
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Sound Settings
                        _buildSettingsSection(
                          title: "تنظیمات صوتی",
                          icon: Icons.volume_up,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          children: [
                            _buildToggleOption(
                              title: "پخش خودکار تلفظ در صفحه واژگان جدید",
                              primaryTextColor: primaryTextColor,
                              value: false,
                              onChanged: (_) {},
                              comingSoon: true,
                            ),
                            _buildToggleOption(
                              title: "پخش خودکار صوت تمرین ها",
                              primaryTextColor: primaryTextColor,
                              value: state.autoPlayExerciseSounds,
                              onChanged: (value) {
                                context
                                    .read<SettingsCubit>()
                                    .updateAutoPlayExerciseSounds(value);
                              },
                              activeColor: MyColors.primary,
                            ),
                            _buildToggleOption(
                              title: "پخش افکت های صوتی",
                              primaryTextColor: primaryTextColor,
                              value: state.playSoundEffects,
                              onChanged: (value) {
                                context
                                    .read<SettingsCubit>()
                                    .updatePlaySoundEffects(value);
                              },
                              activeColor: MyColors.primary,
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Content Text Size
                        _buildSettingsSection(
                          title: "اندازه متون محتوای درسی",
                          icon: Icons.text_fields,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          children: [
                            _buildTextSizeSlider(
                              state.textSize,
                              secondaryTextColor,
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),
                      ],
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

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.r, color: secondaryTextColor),
            SizedBox(width: 8.w),
            Text(
              title,
              style: MyTextStyle.textMatn16Bold.copyWith(
                color: primaryTextColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool value,
    required Color primaryTextColor,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
    bool comingSoon = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: comingSoon
                          ? primaryTextColor.withValues(alpha: 0.5)
                          : primaryTextColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                if (comingSoon) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: MyColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "به زودی",
                      style: MyTextStyle.textMatn12W500.copyWith(
                        color: MyColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: comingSoon ? false : value,
            onChanged: comingSoon ? null : onChanged,
            activeThumbColor: activeColor ?? MyColors.primary,
            activeTrackColor: (activeColor ?? MyColors.primary)
                .withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: MyColors.textSecondary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSlider(double textSize, Color secondaryTextColor) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: MyColors.primary,
            inactiveTrackColor: MyColors.text4.withValues(alpha: 0.3),
            thumbColor: MyColors.primary,
            trackHeight: 4.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
          ),
          child: Slider(
            value: textSize,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              context.read<SettingsCubit>().updateTextSize(value);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "اندازه کوچک",
              style: MyTextStyle.textMatn12W500.copyWith(
                color: secondaryTextColor,
              ),
            ),
            Text(
              "اندازه بزرگ",
              style: MyTextStyle.textMatn12W500.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

}
