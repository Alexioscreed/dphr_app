import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/health_record_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/api_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/vital_measurements_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => VitalMeasurementsProvider()), // Added the new provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Updated to use super.key for Flutter 24

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Apply additional theme overrides for bottom navigation
    final ThemeData theme = themeProvider.isDarkMode
        ? themeProvider.darkTheme.copyWith(
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF00A884),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          color: Color(0xFF00A884),
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.grey,
        ),
      ),
    )
        : themeProvider.lightTheme;

    return MaterialApp(
      title: 'DPHR',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: theme,
      themeMode: themeProvider.flutterThemeMode,
      home: const SplashScreen(),
    );
  }
}
