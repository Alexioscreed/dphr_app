import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_record.dart';
import '../models/encounter.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Cache keys
  static const String _healthRecordsKey = 'cache_health_records';
  static const String _encountersKey = 'cache_encounters';
  static const String _lastSyncKey = 'cache_last_sync';

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

  // Cache health records
  Future<bool> cacheHealthRecords(List<HealthRecord> healthRecords) async {
    await init();
    try {
      final recordsData = healthRecords.map((record) => record.toMap()).toList();
      await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      return await cacheData(_healthRecordsKey, recordsData, 
          expiry: const Duration(hours: 24));
    } catch (e) {
      debugPrint('Error caching health records: $e');
      return false;
    }
  }

  // Get cached health records
  Future<List<HealthRecord>?> getCachedHealthRecords() async {
    await init();
    try {
      final data = await getCachedData(_healthRecordsKey);
      if (data == null) return null;

      final List<dynamic> recordsList = data;
      return recordsList
          .map((recordData) => HealthRecord.fromMap(recordData))
          .toList();
    } catch (e) {
      debugPrint('Error retrieving cached health records: $e');
      return null;
    }
  }

  // Cache encounters
  Future<bool> cacheEncounters(List<Encounter> encounters) async {
    await init();
    try {
      final encountersData = encounters.map((encounter) => encounter.toMap()).toList();
      return await cacheData(_encountersKey, encountersData, 
          expiry: const Duration(hours: 24));
    } catch (e) {
      debugPrint('Error caching encounters: $e');
      return false;
    }
  }

  // Get cached encounters
  Future<List<Encounter>?> getCachedEncounters() async {
    await init();
    try {
      final data = await getCachedData(_encountersKey);
      if (data == null) return null;

      final List<dynamic> encountersList = data;
      return encountersList
          .map((encounterData) => Encounter.fromMap(encounterData))
          .toList();
    } catch (e) {
      debugPrint('Error retrieving cached encounters: $e');
      return null;
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    await init();
    try {
      final syncTimeString = _prefs.getString(_lastSyncKey);
      if (syncTimeString == null) return null;
      return DateTime.parse(syncTimeString);
    } catch (e) {
      debugPrint('Error retrieving last sync time: $e');
      return null;
    }
  }

  // Clear health records cache
  Future<bool> clearHealthRecordsCache() async {
    await init();
    final result1 = await clearCache(_healthRecordsKey);
    final result2 = await clearCache(_encountersKey);
    await _prefs.remove(_lastSyncKey);
    return result1 && result2;
  }

  // Check if cache is fresh (less than specified duration old)
  Future<bool> isCacheFresh({Duration maxAge = const Duration(hours: 6)}) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return false;
    
    final now = DateTime.now();    final age = now.difference(lastSync);
    return age < maxAge;
  }
}

