import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static const String reminderKey = 'daily_reminder_enabled';
  static const String channelId = 'daily_reminder';
  static const String channelName = 'Daily Reminder';
  static const String channelDesc = 'Channel for lunch reminders';

  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final SharedPreferences _prefs;

  NotificationService._(this._prefs) {
    _initializeNotifications();
  }

  static Future<NotificationService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = NotificationService._(prefs);
    }
    return _instance!;
  }

  Future<void> _initializeNotifications() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      debugPrint('Notification service initialized (Asia/Jakarta)');

      const androidSettings = AndroidInitializationSettings(
        'notification_icon',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);

      final platform = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (platform != null) {
        await platform.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> scheduleDailyReminder() async {
    try {
      final isEnabled = _prefs.getBool(reminderKey) ?? false;
      if (!isEnabled) return;

      await _notifications.cancelAll();

      // Schedule for 11:00 AM (WIB)
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        11, // jam 11 AM
        0, // menit ke-00
      );

      // If time has passed, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        0,
        'Waktunya Makan!',
        'Hey! Sudah jam 11:00, ayo cari restaurant favoritmu!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            enableLights: true,
            enableVibration: true,
            playSound: true,
            icon: 'notification_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint(
        'Daily reminder scheduled for ${scheduledDate.hour}:${scheduledDate.minute} WIB',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<bool> toggleReminder() async {
    try {
      final currentValue = _prefs.getBool(reminderKey) ?? false;
      final newValue = !currentValue;

      await _prefs.setBool(reminderKey, newValue);

      if (newValue) {
        await scheduleDailyReminder();
      } else {
        await _notifications.cancelAll();
      }

      return newValue;
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
      return false;
    }
  }

  Future<bool> isReminderEnabled() async {
    return _prefs.getBool(reminderKey) ?? false;
  }
}
