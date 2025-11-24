import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../locator.dart';

class ReminderNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tehran'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android with sound
    const androidChannel = AndroidNotificationChannel(
      'reminder_channel',
      'یادآور مطالعه',
      description: 'یادآوری برای مطالعه لایتنر و درس',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(androidChannel);

    // Request exact alarm permission for Android 12+
    await androidImplementation?.requestExactAlarmsPermission();

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
  }

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required ReminderType type,
    required bool isActive,
  }) async {
    if (!isActive) {
      await cancelReminder(id);
      return;
    }

    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0, // seconds
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('📅 Scheduling reminder:');
    print('   Now: $now');
    print('   Scheduled: $scheduledDate');
    print('   Time: ${time.hour}:${time.minute}');
    print('   ID: $id');

    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'یادآور مطالعه',
      channelDescription: 'یادآوری برای مطالعه لایتنر و درس',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      channelShowBadge: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('✅ Reminder scheduled successfully');
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
      rethrow;
    }

    // Save reminder to SharedPreferences
    await _saveReminder(id, title, body, time, type, isActive);
  }

  static Future<void> _saveReminder(
    int id,
    String title,
    String body,
    TimeOfDay time,
    ReminderType type,
    bool isActive,
  ) async {
    final prefs = locator<SharedPreferences>();
    final remindersJson = prefs.getString('reminders') ?? '[]';
    final reminders =
        List<Map<String, dynamic>>.from(jsonDecode(remindersJson));

    final reminderData = {
      'id': id,
      'title': title,
      'body': body,
      'hour': time.hour,
      'minute': time.minute,
      'type': type.toString(),
      'isActive': isActive,
    };

    final index = reminders.indexWhere((r) => r['id'] == id);
    if (index >= 0) {
      reminders[index] = reminderData;
    } else {
      reminders.add(reminderData);
    }

    await prefs.setString('reminders', jsonEncode(reminders));
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    final prefs = locator<SharedPreferences>();
    final remindersJson = prefs.getString('reminders') ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(remindersJson));
  }

  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
    await _removeReminder(id);
  }

  static Future<void> _removeReminder(int id) async {
    final prefs = locator<SharedPreferences>();
    final remindersJson = prefs.getString('reminders') ?? '[]';
    final reminders =
        List<Map<String, dynamic>>.from(jsonDecode(remindersJson));
    reminders.removeWhere((r) => r['id'] == id);
    await prefs.setString('reminders', jsonEncode(reminders));
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    final prefs = locator<SharedPreferences>();
    await prefs.remove('reminders');
  }

  static Future<void> updateReminderStatus(int id, bool isActive) async {
    final reminders = await getReminders();
    final reminder = reminders.firstWhere((r) => r['id'] == id);

    await scheduleReminder(
      id: id,
      title: reminder['title'],
      body: reminder['body'],
      time: TimeOfDay(
        hour: reminder['hour'],
        minute: reminder['minute'],
      ),
      type: reminder['type'] == 'ReminderType.litner'
          ? ReminderType.litner
          : ReminderType.lesson,
      isActive: isActive,
    );
  }

  // Test method to show immediate notification
  static Future<void> showTestNotification() async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'یادآور مطالعه',
      channelDescription: 'یادآوری برای مطالعه لایتنر و درس',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'تست یادآور',
      'این یک نوتیفیکیشن تست است',
      notificationDetails,
    );
  }

  // Test method to schedule notification in 1 minute
  static Future<void> scheduleTestNotificationIn1Minute() async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(minutes: 1));

    print('📅 Scheduling test notification:');
    print('   Now: $now');
    print('   Scheduled: $scheduledDate (in 1 minute)');

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'یادآور مطالعه',
      channelDescription: 'یادآوری برای مطالعه لایتنر و درس',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        998,
        'تست یادآور (1 دقیقه)',
        'این یک نوتیفیکیشن تست برای 1 دقیقه بعد است',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('✅ Test notification scheduled successfully for 1 minute');
    } catch (e) {
      print('❌ Error scheduling test notification: $e');
      rethrow;
    }
  }
}

enum ReminderType {
  litner,
  lesson,
}
