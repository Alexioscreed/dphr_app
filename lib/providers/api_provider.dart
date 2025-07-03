import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/shared_records_service.dart';
import '../models/shared_record.dart';

class ApiProvider with ChangeNotifier {
  ApiService? _apiService;
  SharedRecordsService? _sharedRecordsService;
  final AuthService _authService = AuthService();
  bool _isInitialized = false;
  bool _isLoading = false;
  String _error = '';
  List<SharedRecord> _sharedRecords = [];

  // Constructor that automatically initializes
  ApiProvider() {
    _initializeAsync();
  }

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String get error => _error;
  ApiService? get apiService => _apiService;
  List<SharedRecord> get sharedRecords => [..._sharedRecords];

  // Private async initialization method
  Future<void> _initializeAsync() async {
    await initialize();
  }

  // Initialize the API provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize auth service first
      await _authService.initialize();

      // Initialize API service with auth service
      _apiService = ApiService(_authService);

      // Initialize shared records service
      _sharedRecordsService = SharedRecordsService(_apiService!, _authService);

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
      // await _apiService.post('clients/register', clientData);

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
    // Ensure the provider is initialized first
    if (!_isInitialized) {
      await initialize();
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Check if shared records service is available
      if (_sharedRecordsService == null) {
        throw Exception('Shared records service not initialized');
      }

      // Fetch real shared records from health data
      _sharedRecords = await _sharedRecordsService!.getSharedRecords();

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

  // Add a new shared record when health data is successfully shared
  void addSharedRecord({
    required String recipientName,
    required String recipientEmail,
    required String visitId,
    required DateTime visitDate,
    String? purpose,
  }) {
    final newRecord = SharedRecord(
      id: 'shared_${DateTime.now().millisecondsSinceEpoch}',
      recipientName: recipientName,
      recipientEmail: recipientEmail,
      recordType: 'Visit',
      sharedDate: visitDate,
      expiryDate: DateTime.now().add(Duration(days: 30)),
      status: 'Complete',
      description: purpose ?? 'Health visit summary shared',
      files: ['visit_summary_${visitId}.pdf'],
    );

    _sharedRecords.insert(0, newRecord); // Add to beginning of list
    notifyListeners();
  }

  // Reset API provider state
  void reset() {
    _isInitialized = false;
    _isLoading = false;
    _error = '';
    _sharedRecords = [];
    _apiService = null;
    _sharedRecordsService = null;
    notifyListeners();
  }
}
