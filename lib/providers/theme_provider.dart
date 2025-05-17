import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define an enum for theme modes
enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  AppThemeMode _themeMode = AppThemeMode.system;
  final String _themePreferenceKey = 'theme_preference';
  final String _themeModePreferenceKey = 'theme_mode_preference';

  bool get isDarkMode => _isDarkMode;
  AppThemeMode get themeMode => _themeMode;
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  // Light theme with blue accent
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF2196F3), // Updated to blue
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF2196F3), // Updated to blue
        secondary: const Color(0xFF1976D2), // Darker blue
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3), // Updated to blue
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF2196F3), // Updated to blue
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2196F3), // Updated to blue
          side: const BorderSide(color: Color(0xFF2196F3)), // Updated to blue
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2196F3)), // Updated to blue
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Dark theme with blue accent
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF2196F3), // Updated to blue
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF2196F3), // Updated to blue
        secondary: const Color(0xFF64B5F6), // Lighter blue for dark mode
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3), // Updated to blue
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF64B5F6), // Lighter blue for dark mode
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF64B5F6), // Lighter blue for dark mode
          side: const BorderSide(color: Color(0xFF64B5F6)), // Lighter blue for dark mode
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF64B5F6)), // Lighter blue for dark mode
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1E1E1E),
      ),
    );
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;

    final themeModeString = prefs.getString(_themeModePreferenceKey);
    if (themeModeString != null) {
      _themeMode = _parseThemeMode(themeModeString);
    }

    notifyListeners();
  }

  AppThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  String _themeModeToPref(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePreferenceKey, _themeModeToPref(mode));
    notifyListeners();
  }

  // Method to initialize theme from cache for app initialization
  Future<void> initializeFromCache() async {
    await _loadThemePreference();
  }
}
