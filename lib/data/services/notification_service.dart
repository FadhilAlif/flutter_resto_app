import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String reminderKey = 'daily_reminder_enabled';

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
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleDailyReminder() async {
    final isEnabled = _prefs.getBool(reminderKey) ?? false;
    if (!isEnabled) return;

    // Batalkan jadwal sebelumnya (opsional: pakai cancel(0) kalau mau tertentu)
    await _notifications.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0,
      'Jangan Lupa Makan Siang Yah!',
      'Hey! Ini saatnya makan siang. Cek restoran favoritmu yuk!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Channel for lunch reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<bool> toggleReminder() async {
    final currentValue = _prefs.getBool(reminderKey) ?? false;
    final newValue = !currentValue;

    await _prefs.setBool(reminderKey, newValue);

    if (newValue) {
      await scheduleDailyReminder();
    } else {
      await _notifications.cancelAll();
    }

    return newValue;
  }

  Future<bool> isReminderEnabled() async {
    return _prefs.getBool(reminderKey) ?? false;
  }
}
