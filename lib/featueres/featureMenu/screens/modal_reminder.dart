import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconify_design/iconify_design.dart';
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
                            '${_selectedTime.hour.toString().toPersianDigit()} : ${_selectedTime.minute.toString().padLeft(2, '0').toPersianDigit()}',
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
                              title: 'یادآوری درس',
                              icon: "material-symbols:checklist",
                              isSelected: _selectedType == ReminderType.lesson,
                              onTap: () {
                                setState(() {
                                  _selectedType = ReminderType.lesson;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ReminderTypeCard(
                              title: 'یادآوری لایتنر',
                              icon: "fluent:flashcards-24-regular",
                              isSelected: _selectedType == ReminderType.litner,
                              onTap: () {
                                setState(() {
                                  _selectedType = ReminderType.litner;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: themeState.isDark
                                      ? MyColors.darkBorder
                                      : MyColors.text4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'لغو',
                                style: MyTextStyle.textMatn14Bold.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveReminder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'افزودن',
                                style: MyTextStyle.textMatnBtn,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ReminderTypeCard({
    super.key,
    required this.title,
    required this.icon,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? selectedBackground : cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? MyColors.primary
                    : (themeState.isDark
                        ? MyColors.darkBorder
                        : Colors.transparent),
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
                            : MyColors.background1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: IconifyIcon(
                      icon: icon,
                      size: 28,
                      color: isSelected
                          ? Colors.white
                          : (themeState.isDark
                              ? MyColors.darkTextPrimary
                              : MyColors.primary),
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

