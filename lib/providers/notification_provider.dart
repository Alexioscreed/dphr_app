import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => [..._notifications];
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    // Initialize with some sample notifications
    _notifications = [
      {
        'id': '1',
        'title': 'Medication Reminder',
        'message': 'Time to take your medication',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
        'type': 'medication',
      },
      {
        'id': '2',
        'title': 'Appointment Reminder',
        'message': 'You have an appointment with Dr. Smith tomorrow at 10:00 AM',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': false,
        'type': 'appointment',
      },
      {
        'id': '3',
        'title': 'Health Alert',
        'message': 'Your blood pressure reading is higher than normal',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
        'type': 'alert',
      },
    ];

    _calculateUnreadCount();
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((notification) => !notification['isRead']).length;
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((notification) => notification['id'] == id);
    if (index >= 0) {
      _notifications[index]['isRead'] = true;
      _calculateUnreadCount();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    if (!notification['isRead']) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void removeNotification(String id) {
    final notification = _notifications.firstWhere(
          (notification) => notification['id'] == id,
      orElse: () => {'isRead': true},
    );

    _notifications.removeWhere((notification) => notification['id'] == id);

    if (!notification['isRead']) {
      _calculateUnreadCount();
    }

    notifyListeners();
  }

  void clearAll() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }
}

