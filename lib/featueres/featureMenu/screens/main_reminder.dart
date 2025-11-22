import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            : const Color(0xFFF6F9FE);
        final cardBackground =
            themeState.isDark ? MyColors.darkCardBackground : Colors.white;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  height: 57,
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(33.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        left: 16,
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
                              size: 24,
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
                                  : const Color(0xFF3D495C),
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
                                size: 64,
                                color: themeState.isDark
                                    ? MyColors.darkTextSecondary
                                    : MyColors.text4,
                              ),
                              const SizedBox(height: 16),
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
                          padding: const EdgeInsets.all(16),
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
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
                    '${time.hour.toString().toPersianDigit()} : ${time.minute.toString().padLeft(2, '0').toPersianDigit()}',
                    style: MyTextStyle.textMatn14Bold.copyWith(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Toggle Switch
                  Switch(
                    value: isActive,
                    onChanged: onToggle,
                    activeColor: MyColors.primary,
                  ),
                ],
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
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
