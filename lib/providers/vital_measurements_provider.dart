import 'package:flutter/material.dart';
import '../models/vital_measurement.dart';

class VitalMeasurementsProvider with ChangeNotifier {
  List<VitalMeasurement> _measurements = [];
  bool _isLoading = false;
  String _error = '';

  List<VitalMeasurement> get measurements => [..._measurements];
  bool get isLoading => _isLoading;
  String get error => _error;

  // Get measurements by type
  List<VitalMeasurement> getMeasurementsByType(String type) {
    return _measurements.where((measurement) => measurement.type == type).toList();
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
      // In a real app, this would be an API call to fetch measurements
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
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

  Future<void> addMeasurement(VitalMeasurement measurement) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to add a measurement
      await Future.delayed(const Duration(seconds: 1));

      _measurements.add(measurement);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMeasurement(VitalMeasurement measurement) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to delete a measurement
      await Future.delayed(const Duration(seconds: 1));

      _measurements.removeWhere(
              (m) => m.type == measurement.type && m.date == measurement.date
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
