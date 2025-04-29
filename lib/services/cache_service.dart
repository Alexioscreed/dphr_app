import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Initialize the cache service
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Cache data with expiration time
  Future<bool> cacheData(String key, dynamic data, {Duration? expiry}) async {
    await init();

    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };

    return await _prefs.setString(key, jsonEncode(cacheItem));
  }

  // Get cached data if it exists and is not expired
  Future<dynamic> getCachedData(String key) async {
    await init();

    final cachedJson = _prefs.getString(key);
    if (cachedJson == null) return null;

    try {
      final cacheItem = jsonDecode(cachedJson);
      final timestamp = cacheItem['timestamp'] as int;
      final expiryMs = cacheItem['expiry'] as int?;

      // Check if data is expired
      if (expiryMs != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiryMs) {
          // Data is expired, remove it
          await _prefs.remove(key);
          return null;
        }
      }

      return cacheItem['data'];
    } catch (e) {
      // If there's an error parsing the cache, remove it
      await _prefs.remove(key);
      return null;
    }
  }

  // Clear specific cached data
  Future<bool> clearCache(String key) async {
    await init();
    return await _prefs.remove(key);
  }

  // Clear all cached data
  Future<bool> clearAllCache() async {
    await init();

    // Only clear keys that are related to cache
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await _prefs.remove(key);
      }
    }

    return true;
  }
}

