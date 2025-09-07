import 'package:flutter/material.dart';
import 'package:flutter_resto_app/data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  late NotificationService _notificationService;
  bool _isReminderEnabled = false;
  bool _isLoading = true;

  bool get isReminderEnabled => _isReminderEnabled;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _initNotification();
  }

  Future<void> _initNotification() async {
    _notificationService = await NotificationService.getInstance();
    _isReminderEnabled = await _notificationService.isReminderEnabled();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReminder() async {
    _isReminderEnabled = !_isReminderEnabled;
    notifyListeners();
    await _notificationService.toggleReminder();
  }
}
