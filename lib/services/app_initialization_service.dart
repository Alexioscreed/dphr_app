import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/health_record_provider.dart';

class AppInitializationService {
  // Singleton pattern
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  // Flag to track if initialization has been completed
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Cached data
  SharedPreferences? _prefs;
  SharedPreferences? get prefs => _prefs;

  // Initialize all app resources in parallel
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Start multiple initialization tasks in parallel
    final futures = <Future>[];

    // Initialize SharedPreferences
    futures.add(SharedPreferences.getInstance().then((value) => _prefs = value));

    // Preload any assets or data
    futures.add(_preloadAssets());

    // Wait for all initialization tasks to complete
    await Future.wait(futures);

    _isInitialized = true;
  }

  // Preload commonly used assets
  Future<void> _preloadAssets() async {
    // Preload images if needed
    PaintingBinding.instance.imageCache.maximumSize = 100; // Set cache size

    // Example of preloading an image
    // await precacheImage(AssetImage('assets/common_image.png'), null);

    // You can preload other assets here
  }

  // Initialize providers with cached data
  void initializeProviders({
    required AuthProvider authProvider,
    required ThemeProvider themeProvider,
    required HealthRecordProvider healthRecordProvider,
  }) {
    // Initialize providers with cached data if available
    if (_prefs != null) {
      // Example: Initialize theme from cached preferences
      final themeModeIndex = _prefs!.getInt('theme_mode');
      if (themeModeIndex != null) {
        themeProvider.initializeFromCache(themeModeIndex);
      }

      // Example: Check if user is logged in from cached token
      final token = _prefs!.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        authProvider.initializeFromCache(token);
      }

      // Initialize other providers as needed
    }
  }
}

