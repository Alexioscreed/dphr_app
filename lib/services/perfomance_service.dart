import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Map to store performance metrics
  final Map<String, List<double>> _metrics = {};

  // Start times for operations
  final Map<String, DateTime> _startTimes = {};

  // Start timing an operation
  void startTiming(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  // End timing an operation and record the duration
  void endTiming(String operationName) {
    final startTime = _startTimes[operationName];
    if (startTime == null) {
      debugPrint('Warning: No start time found for operation $operationName');
      return;
    }

    final duration = DateTime.now().difference(startTime).inMilliseconds.toDouble();

    if (!_metrics.containsKey(operationName)) {
      _metrics[operationName] = [];
    }

    _metrics[operationName]!.add(duration);

    // Log the performance metric
    debugPrint('Performance: $operationName took ${duration.toStringAsFixed(2)} ms');

    // Remove the start time
    _startTimes.remove(operationName);
  }

  // Get average duration for an operation
  double getAverageDuration(String operationName) {
    final durations = _metrics[operationName];
    if (durations == null || durations.isEmpty) {
      return 0;
    }

    final sum = durations.reduce((a, b) => a + b);
    return sum / durations.length;
  }

  // Save performance metrics to persistent storage
  Future<void> saveMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert metrics to a format that can be stored
      final Map<String, String> serializedMetrics = {};

      _metrics.forEach((key, value) {
        serializedMetrics[key] = value.join(',');
      });

      // Save each metric separately
      for (final entry in serializedMetrics.entries) {
        await prefs.setString('perf_${entry.key}', entry.value);
      }
    } catch (e) {
      debugPrint('Error saving performance metrics: $e');
    }
  }

  // Load performance metrics from persistent storage
  Future<void> loadMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all keys that start with 'perf_'
      final keys = prefs.getKeys().where((key) => key.startsWith('perf_')).toList();

      // Load each metric
      for (final key in keys) {
        final operationName = key.substring(5); // Remove 'perf_' prefix
        final serializedValues = prefs.getString(key);

        if (serializedValues != null && serializedValues.isNotEmpty) {
          final values = serializedValues.split(',').map((s) => double.parse(s)).toList();
          _metrics[operationName] = values;
        }
      }
    } catch (e) {
      debugPrint('Error loading performance metrics: $e');
    }
  }

  // Clear all performance metrics
  Future<void> clearMetrics() async {
    _metrics.clear();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all keys that start with 'perf_'
      final keys = prefs.getKeys().where((key) => key.startsWith('perf_')).toList();

      // Remove each metric
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing performance metrics: $e');
    }
  }
}

