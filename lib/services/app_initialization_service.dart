import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/health_record_provider.dart';
import '../providers/api_provider.dart';
import '../providers/vital_measurements_provider.dart';

class AppInitializationService {
  static Future<void> initialize(BuildContext context) async {
    await _initializeProviders(context);
    await _loadInitialData(context);
  }

  static Future<void> _initializeProviders(BuildContext context) async {
    // Initialize API provider first
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    await apiProvider.initialize();

    // Initialize auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    // Initialize theme provider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.initializeFromCache();

    // Initialize notification provider
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.initialize();
  }

  static Future<void> _loadInitialData(BuildContext context) async {
    // Check if user is authenticated before loading data
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      // Load health records
      final healthRecordProvider =
          Provider.of<HealthRecordProvider>(context, listen: false);
      await healthRecordProvider.fetchHealthRecords();

      // Load vital measurements
      final vitalMeasurementsProvider =
          Provider.of<VitalMeasurementsProvider>(context, listen: false);
      await vitalMeasurementsProvider.fetchMeasurements();
    }
  }
}
