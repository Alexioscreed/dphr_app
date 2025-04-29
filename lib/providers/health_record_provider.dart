import 'package:flutter/material.dart';
import '../models/health_record.dart';

class HealthRecordProvider with ChangeNotifier {
  List<HealthRecord> _records = [];
  bool _isLoading = false;
  String _error = '';

  List<HealthRecord> get records => [..._records];
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchRecords() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, this would be an API call to fetch records
      await Future.delayed(const Duration(seconds: 1));

      // Sample data
      _records = [
        HealthRecord(
          id: '1',
          title: 'Annual Check-up',
          date: DateTime(2023, 5, 15),
          provider: 'Dr. John Smith',
          type: 'Medical',
          description: 'Regular annual physical examination',
          attachments: ['Physical Exam Report', 'Vitals'],
        ),
        HealthRecord(
          id: '2',
          title: 'Blood Test Results',
          date: DateTime(2023, 4, 10),
          provider: 'City Lab',
          type: 'Lab Tests',
          description: 'Complete blood count and metabolic panel',
          attachments: ['CBC Results', 'Metabolic Panel'],
        ),
        // Add more sample records as needed
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to add a record
      await Future.delayed(const Duration(seconds: 1));

      _records.add(record);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to update a record
      await Future.delayed(const Duration(seconds: 1));

      final index = _records.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        _records[index] = record;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would be an API call to delete a record
      await Future.delayed(const Duration(seconds: 1));

      _records.removeWhere((record) => record.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

