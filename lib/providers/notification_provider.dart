import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/health_analytics_service.dart';
import '../models/vital_measurement.dart';
import '../models/symptom.dart';

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
          title: 'Health Check Reminder',
          message: 'Remember to check your blood pressure today.',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'health_risk',
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
    _notifications = _notifications
        .map((notification) => Notification(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              date: notification.date,
              isRead: true,
              type: notification.type,
            ))
        .toList();

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

  // Add health risk notifications
  Future<void> addHealthRiskNotifications(List<HealthRisk> risks) async {
    if (!_notificationsEnabled) return;

    for (var risk in risks) {
      // Check if we already have a notification for this risk type today
      final today = DateTime.now();
      final existingRisk = _notifications
          .where((n) =>
              n.type == 'health_risk' &&
              n.title.contains(risk.type) &&
              n.date.year == today.year &&
              n.date.month == today.month &&
              n.date.day == today.day)
          .isNotEmpty;

      if (!existingRisk) {
        await addNotification(
          title: risk.title,
          message:
              '${risk.description}\n\nRecommendation: ${risk.recommendation}',
          type: 'health_risk',
        );
      }
    }
  }

  // Analyze health data and create notifications
  Future<void> analyzeHealthDataAndNotify({
    List<VitalMeasurement>? vitals,
    List<Symptom>? symptoms,
  }) async {
    try {
      List<HealthRisk> allRisks = [];

      // Analyze vitals if provided
      if (vitals != null && vitals.isNotEmpty) {
        final vitalRisks =
            HealthAnalyticsService.analyzeVitalMeasurements(vitals);
        allRisks.addAll(vitalRisks);
      }

      // Analyze symptoms if provided
      if (symptoms != null && symptoms.isNotEmpty) {
        final symptomRisks = HealthAnalyticsService.analyzeSymptoms(symptoms);
        allRisks.addAll(symptomRisks);
      }

      // Filter only high and critical risks for notifications
      final highRisks = allRisks
          .where(
              (risk) => risk.severity == 'HIGH' || risk.severity == 'CRITICAL')
          .toList();

      if (highRisks.isNotEmpty) {
        await addHealthRiskNotifications(highRisks);
      }
    } catch (e) {
      debugPrint('Error analyzing health data: $e');
    }
  }

  // Add a general notification
  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      date: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, notification); // Add to beginning
    notifyListeners();

    // In a real app, you would save this to a database or API
  }
}
