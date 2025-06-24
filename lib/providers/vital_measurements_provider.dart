import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vital_measurement.dart';
import '../models/symptom.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart' as notifications;

class VitalMeasurementsProvider with ChangeNotifier {
  List<VitalMeasurement> _measurements = [];
  List<Symptom> _symptoms = [];
  bool _isLoading = false;
  String _error = '';

  List<VitalMeasurement> get measurements => [..._measurements];
  List<Symptom> get symptoms => [..._symptoms];
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get measurements by type
  List<VitalMeasurement> getMeasurementsByType(String type) {
    return _measurements
        .where((measurement) => measurement.type == type)
        .toList();
  }

  // Get latest measurement by type
  VitalMeasurement? getLatestMeasurementByType(String type) {
    final typeList = getMeasurementsByType(type);
    if (typeList.isEmpty) return null;

    // Sort by date (newest first) and return the first one
    typeList.sort((a, b) => b.date.compareTo(a.date));
    return typeList.first;
  }

  Future<void> fetchMeasurements() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // For now, use sample data with some real API structure
      // In production, this would fetch from the backend
      await Future.delayed(const Duration(seconds: 1));

      // Sample data - in real implementation, this would be fetched from API
      _measurements = [
        VitalMeasurement(
          type: 'Blood Pressure',
          value: '120/80 mmHg',
          date: DateTime.now().subtract(const Duration(days: 1)),
          notes: 'Measured after rest',
        ),
        VitalMeasurement(
          type: 'Heart Rate',
          value: '72 bpm',
          date: DateTime.now().subtract(const Duration(days: 2)),
          notes: 'Measured at rest',
        ),
        VitalMeasurement(
          type: 'Blood Glucose',
          value: '95 mg/dL',
          date: DateTime.now().subtract(const Duration(days: 3)),
          notes: 'Fasting',
        ),
        VitalMeasurement(
          type: 'Weight',
          value: '75 kg',
          date: DateTime.now().subtract(const Duration(days: 7)),
          notes: '',
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

  // Add a new symptom and trigger health analysis
  Future<void> addSymptom(Symptom symptom, BuildContext context) async {
    _symptoms.insert(0, symptom);
    notifyListeners();

    // Trigger health analysis
    await _analyzeHealthData(context);
  }

  // Analyze health data and trigger notifications
  Future<void> _analyzeHealthData(BuildContext context) async {
    try {
      final notificationProvider =
          Provider.of<notifications.NotificationProvider>(context,
              listen: false);

      await notificationProvider.analyzeHealthDataAndNotify(
        vitals: _measurements,
        symptoms: _symptoms,
      );
    } catch (e) {
      debugPrint('Error during health analysis: $e');
    }
  }

  // Add a new measurement and trigger health analysis
  Future<void> addMeasurement(VitalMeasurement measurement,
      [BuildContext? context]) async {
    _measurements.insert(0, measurement);
    notifyListeners();

    // Trigger health analysis if context provided
    if (context != null) {
      await _analyzeHealthData(context);
    }
  }

  Future<void> deleteMeasurement(VitalMeasurement measurement) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to delete a measurement
      await Future.delayed(const Duration(seconds: 1));

      _measurements.removeWhere(
          (m) => m.type == measurement.type && m.date == measurement.date);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
