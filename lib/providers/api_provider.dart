import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/shared_record.dart';

class ApiProvider with ChangeNotifier {
  late ApiService _apiService;
  bool _isInitialized = false;
  bool _isLoading = false;
  String _error = '';
  List<SharedRecord> _sharedRecords = [];

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String get error => _error;
  ApiService get apiService => _apiService;
  List<SharedRecord> get sharedRecords => [..._sharedRecords];

  // Initialize the API provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize API service with configuration
      // In a real app, these would come from secure storage or environment variables
      _apiService = ApiService(
        baseUrl: 'https://api.example.com/v1',
        username: 'dphr_app',
        password: 'secure_password',
        hfrCode: 'HFR123',
      );

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset error state
  void resetError() {
    _error = '';
    notifyListeners();
  }

  // Register a client
  Future<bool> registerClient(Map<String, dynamic> clientData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, this would call the API service
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Uncomment in a real app:
      // await _apiService.registerClient(clientData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch shared records
  Future<void> fetchSharedRecords() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // In a real app, this would call the API service
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Sample data for development - updated to patient-to-person sharing
      _sharedRecords = [
        SharedRecord(
          id: '1',
          recipientName: 'Dr. Sarah Johnson',
          recipientEmail: 'sarah.johnson@hospital.com',
          recordType: 'Lab Results',
          sharedDate: DateTime.now().subtract(const Duration(days: 2)),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          status: 'Active',
          description: 'Blood work results from annual checkup',
          files: ['lab_results.pdf'],
        ),
        SharedRecord(
          id: '2',
          recipientName: 'Dr. Michael Brown',
          recipientEmail: 'michael.brown@clinic.org',
          recordType: 'Prescription',
          sharedDate: DateTime.now().subtract(const Duration(days: 5)),
          expiryDate: DateTime.now().add(const Duration(days: 25)),
          status: 'Active',
          description: 'Prescription for hypertension medication',
          files: ['prescription.pdf'],
        ),
        SharedRecord(
          id: '3',
          recipientName: 'Emma Davis (Family)',
          recipientEmail: 'emma.davis@example.com',
          recordType: 'Radiology',
          sharedDate: DateTime.now().subtract(const Duration(days: 10)),
          expiryDate: DateTime.now().add(const Duration(days: 20)),
          status: 'Active',
          description: 'Chest X-ray results',
          files: ['xray_report.pdf', 'xray_image.jpg'],
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

  // Get shared record by ID
  SharedRecord? getSharedRecordById(String id) {
    try {
      return _sharedRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  // Reset API provider state
  void reset() {
    _isInitialized = false;
    _isLoading = false;
    _error = '';
    _sharedRecords = [];
    notifyListeners();
  }
}
