import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

/// Optional enhancement: Frontend cache management methods
/// These are NOT required - just optional features for cache control
class HealthRecordsCacheEnhancement {
  final ApiService _apiService;

  HealthRecordsCacheEnhancement(this._apiService);

  /// Force sync health records from iCare (bypass cache)
  Future<Map<String, dynamic>> forceSyncHealthRecords() async {
    try {
      debugPrint('Force syncing health records from iCare');

      final response =
          await _apiService.post('health-records/cache/force-sync', {});

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Force sync response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from force sync API');
      }
    } catch (e) {
      debugPrint('Error during force sync: $e');
      throw Exception('Failed to force sync health records: $e');
    }
  }

  /// Get cache status for current user
  Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      debugPrint('Getting cache status');

      final response = await _apiService.get('health-records/cache/status');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Cache status response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from cache status API');
      }
    } catch (e) {
      debugPrint('Error getting cache status: $e');
      throw Exception('Failed to get cache status: $e');
    }
  }

  /// Clear cached health records (next request will fetch fresh data)
  Future<Map<String, dynamic>> clearCache() async {
    try {
      debugPrint('Clearing health records cache');

      final response = await _apiService.delete('health-records/cache/clear');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Clear cache response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from clear cache API');
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Check if user should get fresh data (first time access)
  Future<bool> shouldGetFreshData() async {
    try {
      final status = await getCacheStatus();
      return status['shouldGetFreshData'] ?? false;
    } catch (e) {
      debugPrint('Error checking fresh data status: $e');
      return false;
    }
  }

  /// Check if this is user's first time accessing health records
  Future<bool> isFirstTimeAccess() async {
    try {
      final status = await getCacheStatus();
      return status['isFirstTimeAccess'] ?? false;
    } catch (e) {
      debugPrint('Error checking first time access: $e');
      return false;
    }
  }
}

// Optional: Add these methods to existing HealthRecordsService
// You can copy these methods into your existing health_records_service.dart if desired

/// Extension methods to add cache management to existing HealthRecordsService
/// Usage: Just copy these methods into your existing HealthRecordsService class
/*
  // OPTIONAL: Add these methods to HealthRecordsService for cache management

  /// Force sync health records from iCare (bypass cache)
  Future<Map<String, dynamic>> forceSyncHealthRecords() async {
    try {
      debugPrint('Force syncing health records from iCare');
      final response = await _apiService.post('health-records/cache/force-sync', {});
      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Force sync response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from force sync API');
      }
    } catch (e) {
      debugPrint('Error during force sync: $e');
      throw Exception('Failed to force sync health records: $e');
    }
  }

  /// Get cache status for current user
  Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      debugPrint('Getting cache status');
      final response = await _apiService.get('health-records/cache/status');
      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Cache status response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from cache status API');
      }
    } catch (e) {
      debugPrint('Error getting cache status: $e');
      throw Exception('Failed to get cache status: $e');
    }
  }

  /// Clear cached health records (next request will fetch fresh data)
  Future<Map<String, dynamic>> clearCache() async {
    try {
      debugPrint('Clearing health records cache');
      final response = await _apiService.delete('health-records/cache/clear');
      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Clear cache response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from clear cache API');
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      throw Exception('Failed to clear cache: $e');
    }
  }
*/
