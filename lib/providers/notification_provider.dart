import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    required this.type,
  });
}

class NotificationProvider with ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  String _error = '';
  bool _notificationsEnabled = true;
  final String _notificationsEnabledKey = 'notifications_enabled';

  List<Notification> get notifications => [..._notifications];
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get notificationsEnabled => _notificationsEnabled;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Initialize notification provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load notification settings
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;

      // Load notifications (in a real app, this would be from a database or API)
      await fetchNotifications();

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample notifications
      _notifications = [
        Notification(
          id: '1',
          title: 'Appointment Reminder',
          message: 'You have an appointment with Dr. Smith tomorrow at 10:00 AM.',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'appointment',
        ),
        Notification(
          id: '2',
          title: 'Medication Reminder',
          message: 'Time to take your medication.',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          type: 'medication',
        ),
        Notification(
          id: '3',
          title: 'Health Record Updated',
          message: 'Your health record has been updated with new lab results.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          type: 'record',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      final updatedNotification = Notification(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        date: notification.date,
        isRead: true,
        type: notification.type,
      );

      _notifications[index] = updatedNotification;
      notifyListeners();

      // In a real app, you would update this in a database or API
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((notification) => Notification(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      date: notification.date,
      isRead: true,
      type: notification.type,
    )).toList();

    notifyListeners();

    // In a real app, you would update this in a database or API
  }

  // Toggle notifications enabled
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;

    // Save setting
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    notifyListeners();
  }
}
