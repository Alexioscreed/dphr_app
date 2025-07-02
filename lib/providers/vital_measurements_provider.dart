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
      // This will be injected via constructor - using a placeholder for now
      // The actual API service will be provided when this is used
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch measurements by patient UUID
  Future<void> fetchMeasurementsByPatientUuid(
      String patientUuid, ApiService apiService) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response =
          await apiService.get('vital-signs/patient-uuid/$patientUuid');

      if (response is List) {
        _measurements = response.map<VitalMeasurement>((json) {
          return VitalMeasurement(
            type: json['type'] ?? '',
            value: json['value'] ?? '',
            date: DateTime.parse(json['recordedAt']),
            notes: json['notes'] ?? '',
          );
        }).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch measurements by type and date range
  Future<List<VitalMeasurement>> fetchMeasurementsByTypeAndDateRange(
      String patientUuid,
      String type,
      DateTime startDate,
      DateTime endDate,
      ApiService apiService) async {
    try {
      final startDateStr = startDate.toIso8601String();
      final endDateStr = endDate.toIso8601String();

      final response = await apiService.get(
          'vital-signs/patient-uuid/$patientUuid/date-range?startDate=$startDateStr&endDate=$endDateStr&type=$type');

      if (response is List) {
        return response.map<VitalMeasurement>((json) {
          return VitalMeasurement(
            type: json['type'] ?? '',
            value: json['value'] ?? '',
            date: DateTime.parse(json['recordedAt']),
            notes: json['notes'] ?? '',
          );
        }).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch measurements: $e');
    }
  }

  // Fetch latest measurement by type
  Future<VitalMeasurement?> fetchLatestMeasurementByType(
      String patientUuid, String type, ApiService apiService) async {
    try {
      final response = await apiService
          .get('vital-signs/patient-uuid/$patientUuid/latest/$type');

      if (response != null) {
        return VitalMeasurement(
          type: response['type'] ?? '',
          value: response['value'] ?? '',
          date: DateTime.parse(response['recordedAt']),
          notes: response['notes'] ?? '',
        );
      }

      return null;
    } catch (e) {
      // Return null if no measurement found, don't throw error
      return null;
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
