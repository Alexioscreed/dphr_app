import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/dashboard_screen.dart';

class RouteHandler {
  static Future<void> handleAuthNavigation(
      BuildContext context,
      AuthProvider authProvider,
      ) async {
    // Initialize auth provider if needed
    await authProvider.initialize();

    // Use isAuthenticated property directly
    final isAuthenticated = authProvider.isAuthenticated;

    if (!isAuthenticated) {
      // Navigate to login if not authenticated
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    } else {
      // Navigate to dashboard if authenticated
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
        );
      }
    }
  }
}
