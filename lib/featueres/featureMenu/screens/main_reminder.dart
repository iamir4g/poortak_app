import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:poortak/common/bloc/theme_cubit/theme_cubit.dart';
import 'package:poortak/common/services/reminder_notification_service.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:poortak/featueres/featureMenu/screens/modal_reminder.dart';

class ReminderScreen extends StatefulWidget {
  static const String routeName = '/reminder';

  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await ReminderNotificationService.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  void _showAddReminderModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReminderModal(
        onReminderAdded: () {
          _loadReminders();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final backgroundColor = themeState.isDark
            ? MyColors.darkBackground
            : MyColors.background3;
        final cardBackground =
            themeState.isDark ? MyColors.darkCardBackground : Colors.white;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  height: 57.h,
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(33.5.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, 1.h),
                        blurRadius: 1.r,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        left: 16.w,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_forward,
                              color: themeState.isDark
                                  ? MyColors.darkTextPrimary
                                  : MyColors.textMatn1,
                              size: 24.r,
                            ),
                          ),
                        ),
                      ),
                      // Title
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            'یادآور مطالعه',
                            style: MyTextStyle.textHeader16Bold.copyWith(
                              color: themeState.isDark
                                  ? MyColors.darkTextPrimary
                                  : MyColors.textCancelButton,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Reminders List
                Expanded(
                  child: _reminders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconifyIcon(
                                icon: "ic:baseline-more-time",
                                size: 64.r,
                                color: themeState.isDark
                                    ? MyColors.darkTextSecondary
                                    : MyColors.text4,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'یادآوری تنظیم نشده است',
                                style: MyTextStyle.textMatn14Bold.copyWith(
                                  color: themeState.isDark
                                      ? MyColors.darkTextSecondary
                                      : MyColors.text4,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16.r),
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            return ReminderCard(
                              reminder: reminder,
                              onToggle: (isActive) async {
                                await ReminderNotificationService
                                    .updateReminderStatus(
                                  reminder['id'],
                                  isActive,
                                );
                                _loadReminders();
                              },
                              onDelete: () async {
                                await ReminderNotificationService
                                    .cancelReminder(reminder['id']);
                                _loadReminders();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddReminderModal,
            backgroundColor: MyColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class ReminderCard extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final cardBackground =
            themeState.isDark ? MyColors.darkCardBackground : Colors.white;
        final textColor =
            themeState.isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;
        final secondaryTextColor =
            themeState.isDark ? MyColors.darkTextSecondary : MyColors.text3;

        final time = TimeOfDay(
          hour: reminder['hour'],
          minute: reminder['minute'],
        );
        final isActive = reminder['isActive'] ?? true;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, 2.h),
                blurRadius: 4.r,
              ),
            ],
          ),
          child: Row(
            children: [
              // Time Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${time.hour.toString().padLeft(2, '0').toPersianDigit()} : ${time.minute.toString().padLeft(2, '0').toPersianDigit()}',
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: textColor,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Toggle Switch
                  Switch(
                    value: isActive,
                    onChanged: onToggle,
                    activeThumbColor: MyColors.primary,
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder['title'],
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'هر روز',
                      style: MyTextStyle.textMatn12W300.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('حذف یادآور'),
                      content:
                          const Text('آیا از حذف این یادآور اطمینان دارید؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('لغو'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          child: const Text('حذف',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: themeState.isDark
                      ? MyColors.darkTextSecondary
                      : MyColors.text3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
