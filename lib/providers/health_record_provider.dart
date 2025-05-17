import 'package:flutter/material.dart';
import '../models/health_record.dart';

class HealthRecordProvider with ChangeNotifier {
  List<HealthRecord> _healthRecords = [];
  bool _isLoading = false;
  String _error = '';

  List<HealthRecord> get healthRecords => [..._healthRecords];
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch health records
  Future<void> fetchHealthRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample health records
      _healthRecords = [
        HealthRecord(
          id: '1',
          title: 'Annual Physical Examination',
          date: DateTime.now().subtract(const Duration(days: 30)),
          provider: 'Dr. John Smith',
          type: 'Examination',
          description: 'Annual physical examination with blood work and vitals check.',
          attachments: ['physical_exam_report.pdf', 'blood_work_results.pdf'],
        ),
        HealthRecord(
          id: '2',
          title: 'COVID-19 Vaccination',
          date: DateTime.now().subtract(const Duration(days: 60)),
          provider: 'City Health Department',
          type: 'Vaccination',
          description: 'COVID-19 vaccination - Pfizer BioNTech, 2nd dose.',
          attachments: ['vaccination_certificate.pdf'],
        ),
        HealthRecord(
          id: '3',
          title: 'Dental Checkup',
          date: DateTime.now().subtract(const Duration(days: 90)),
          provider: 'Dr. Sarah Johnson',
          type: 'Dental',
          description: 'Regular dental checkup and cleaning.',
          attachments: ['dental_xrays.jpg', 'dental_report.pdf'],
        ),
        HealthRecord(
          id: '4',
          title: 'Allergy Test Results',
          date: DateTime.now().subtract(const Duration(days: 120)),
          provider: 'Allergy Specialists Inc.',
          type: 'Laboratory',
          description: 'Comprehensive allergy panel testing for food and environmental allergies.',
          attachments: ['allergy_test_results.pdf'],
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

  // Get health record by ID
  HealthRecord? getHealthRecordById(String id) {
    try {
      return _healthRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add health record
  Future<void> addHealthRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _healthRecords.add(record);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete health record
  Future<void> deleteHealthRecord(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _healthRecords.removeWhere((record) => record.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
