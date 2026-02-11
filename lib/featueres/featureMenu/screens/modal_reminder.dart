import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';
import 'package:poortak/common/services/reminder_notification_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class AddReminderModal extends StatefulWidget {
  final VoidCallback onReminderAdded;

  const AddReminderModal({super.key, required this.onReminderAdded});

  @override
  State<AddReminderModal> createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<AddReminderModal> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  ReminderType? _selectedType;

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MyColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا نوع یادآور را انتخاب کنید')),
      );
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final title =
        _selectedType == ReminderType.litner ? 'یادآوری لایتنر' : 'یادآوری درس';
    final body = _selectedType == ReminderType.litner
        ? 'زمان مطالعه لایتنر فرا رسیده است'
        : 'زمان مطالعه درس فرا رسیده است';

    await ReminderNotificationService.scheduleReminder(
      id: id,
      title: title,
      body: body,
      time: _selectedTime,
      type: _selectedType!,
      isActive: true,
    );

    widget.onReminderAdded();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('یادآور با موفقیت اضافه شد')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final backgroundColor =
            themeState.isDark ? MyColors.darkBackground : Colors.white;
        final textColor =
            themeState.isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;

        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeState.isDark
                      ? MyColors.darkTextSecondary
                      : MyColors.text4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Time Display
                      GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            '${_selectedTime.minute.toString().padLeft(2, '0').toPersianDigit()} : ${_selectedTime.hour.toString().padLeft(2, '0').toPersianDigit()} ',
                            textAlign: TextAlign.center,
                            style: MyTextStyle.textMatn17W700.copyWith(
                              color: textColor,
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Question
                      Text(
                        'یاد آور برای کدام بخش تنظیم شود؟',
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Reminder Type Cards
                      Row(
                        children: [
                          Expanded(
                            child: ReminderTypeCard(
                              title: 'یادآوری لایتنر',
                              iconPath: "assets/images/icons/litner_icon.png",
                              isSelected: _selectedType == ReminderType.litner,
                              onTap: () {
                                setState(() {
                                  _selectedType = ReminderType.litner;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ReminderTypeCard(
                              title: 'یادآوری درس',
                              iconPath: "assets/images/icons/leason_list.png",
                              isSelected: _selectedType == ReminderType.lesson,
                              onTap: () {
                                setState(() {
                                  _selectedType = ReminderType.lesson;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Test Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await ReminderNotificationService
                                      .showTestNotification();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('نوتیفیکیشن فوری ارسال شد'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('خطا: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.notifications_active,
                                size: 18,
                                color: themeState.isDark
                                    ? MyColors.darkTextPrimary
                                    : MyColors.primary,
                              ),
                              label: Text(
                                'تست فوری',
                                style: MyTextStyle.textMatn12Bold.copyWith(
                                  color: themeState.isDark
                                      ? MyColors.darkTextPrimary
                                      : MyColors.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: themeState.isDark
                                      ? MyColors.darkBorder
                                      : MyColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await ReminderNotificationService
                                      .scheduleTestNotificationIn1Minute();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'نوتیفیکیشن برای 1 دقیقه بعد تنظیم شد'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('خطا: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.schedule,
                                size: 18,
                                color: themeState.isDark
                                    ? MyColors.darkTextPrimary
                                    : MyColors.primary,
                              ),
                              label: Text(
                                'تست 1 دقیقه',
                                style: MyTextStyle.textMatn12Bold.copyWith(
                                  color: themeState.isDark
                                      ? MyColors.darkTextPrimary
                                      : MyColors.primary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: themeState.isDark
                                      ? MyColors.darkBorder
                                      : MyColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveReminder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'افزودن',
                                style: MyTextStyle.textMatnBtn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 128,
                            height: 58,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: themeState.isDark
                                      ? MyColors.darkBorder
                                      : MyColors.text4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'لغو',
                                style: MyTextStyle.textMatn14Bold.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReminderTypeCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const ReminderTypeCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final cardBackground =
            themeState.isDark ? MyColors.darkCardBackground : Colors.white;
        final selectedBackground = themeState.isDark
            ? MyColors.darkCardBackground
            : MyColors.primaryTint3;
        final textColor =
            themeState.isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 154,
            height: 136,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? selectedBackground : cardBackground,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? MyColors.primary
                    : (themeState.isDark ? MyColors.darkBorder : Colors.black),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColors.primary
                        : (themeState.isDark
                            ? MyColors.darkCardBackground
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(
                      iconPath,
                      width: 32,
                      height: 32,
                      color: isSelected
                          ? Colors.black
                          : (themeState.isDark
                              ? MyColors.darkTextPrimary
                              : Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: MyTextStyle.textMatn14Bold.copyWith(
                    color: textColor,
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
