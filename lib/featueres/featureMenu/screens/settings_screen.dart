import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/bloc/settings_cubit/settings_cubit.dart';
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: MyColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

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
                          children: [
                            _buildToggleOption(
                              title: "نمایش اپلیکیشن به صورت تمام صفحه",
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
                          children: [
                            _buildToggleOption(
                              title: "دریافت اعلان هنگام دستاورد جدید",
                              value: state.achievementNotifications,
                              onChanged: (value) {
                                context
                                    .read<SettingsCubit>()
                                    .updateAchievementNotifications(value);
                              },
                              activeColor: MyColors.primary,
                            ),
                            _buildToggleOption(
                              title: "دریافت اعلان های عمومی",
                              value: state.generalNotifications,
                              onChanged: (value) {
                                context
                                    .read<SettingsCubit>()
                                    .updateGeneralNotifications(value);
                              },
                              activeColor: MyColors.primary,
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Sound Settings
                        _buildSettingsSection(
                          title: "تنظیمات صوتی",
                          icon: Icons.volume_up,
                          children: [
                            _buildToggleOption(
                              title: "پخش خودکار تلفظ در صفحه واژگان جدید",
                              value: state.autoPlayPronunciation,
                              onChanged: (value) {
                                context
                                    .read<SettingsCubit>()
                                    .updateAutoPlayPronunciation(value);
                              },
                              activeColor: MyColors.primary,
                            ),
                            _buildToggleOption(
                              title: "پخش خودکار صوت تمرین ها",
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
                          children: [
                            _buildTextSizeSlider(state.textSize),
                          ],
                        ),

                        SizedBox(height: 40.h),

                        // Test Text Box
                        _buildTestTextBox(state.textSize),

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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios,
                size: 24.r, color: MyColors.textMatn1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              "تنظیمات",
              textAlign: TextAlign.center,
              style: MyTextStyle.textHeader16Bold.copyWith(
                fontSize: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 24.r), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.r, color: MyColors.textSecondary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: MyTextStyle.textMatn16Bold.copyWith(
                color: MyColors.textMatn1,
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
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: MyTextStyle.textMatn14Bold.copyWith(
                color: MyColors.textMatn1,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor ?? MyColors.textSecondary,
            activeTrackColor: activeColor?.withOpacity(0.3) ??
                MyColors.textSecondary.withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: MyColors.textSecondary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSlider(double textSize) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: MyColors.primary,
            inactiveTrackColor: MyColors.text4.withOpacity(0.3),
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
                color: MyColors.textSecondary,
              ),
            ),
            Text(
              "اندازه بزرگ",
              style: MyTextStyle.textMatn12W500.copyWith(
                color: MyColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestTextBox(double textSize) {
    // محاسبه اندازه فونت بر اساس مقدار اسلایدر
    // حداقل 12 و حداکثر 24 پیکسل
    double fontSize = 12 + (textSize * 12);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: MyColors.background2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        "این یک متن آزمایشی است",
        textAlign: TextAlign.center,
        style: MyTextStyle.textMatn14Bold.copyWith(
          fontSize: fontSize.sp,
          color: MyColors.textMatn1,
        ),
      ),
    );
  }
}
