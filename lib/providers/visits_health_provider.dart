import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/patient_health_records.dart';
import '../services/health_records_service.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/cache_service.dart';

class VisitsHealthProvider with ChangeNotifier {
  final HealthRecordsService _healthRecordsService;
  final AuthService _authService;
  final ConnectivityService _connectivityService;
  final CacheService _cacheService;

  PatientHealthRecords? _healthRecords;
  bool _isLoading = false;
  String _error = '';
  bool _isOffline = false;
  DateTime? _lastSyncTime;
  bool _patientFound = false;
  String? _connectionStatus;
  Map<String, dynamic>? _healthSummary;

  VisitsHealthProvider(
    this._healthRecordsService,
    this._authService,
    this._connectivityService,
    this._cacheService,
  ) {
    _connectivityService.addListener(_onConnectivityChanged);
    _isOffline = !_connectivityService.isOnline;
  }

  // Getters
  PatientHealthRecords? get healthRecords => _healthRecords;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isOffline => _isOffline;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get patientFound => _patientFound;
  String? get connectionStatus => _connectionStatus;
  Map<String, dynamic>? get healthSummary => _healthSummary;

  void _onConnectivityChanged() {
    final wasOffline = _isOffline;
    _isOffline = !_connectivityService.isOnline;

    if (wasOffline && !_isOffline) {
      // Just came back online, try to sync
      debugPrint('Connectivity restored, attempting to sync health records');
      fetchMyHealthRecords();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  /// Test connection to iCare system
  Future<void> testConnection() async {
    try {
      final response = await _healthRecordsService.testConnection();
      _connectionStatus =
          response['connected'] == true ? 'Connected' : 'Disconnected';
      debugPrint('iCare connection status: $_connectionStatus');
    } catch (e) {
      _connectionStatus = 'Connection Failed';
      debugPrint('Failed to test iCare connection: $e');
    }
    notifyListeners();
  }

  /// Fetch health records for the authenticated user
  Future<void> fetchMyHealthRecords({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = '';
    _patientFound = false;
    notifyListeners();

    try {
      // Get current user
      final currentUser = _authService.currentUser;
      if (currentUser?.email == null) {
        throw Exception('No authenticated user found. Please login again.');
      }

      // Check if we should load from cache first
      const cacheKey = 'my_health_records';
      if (!forceRefresh &&
          (!_connectivityService.isOnline ||
              await _cacheService.isCacheFresh())) {
        await _loadFromCache(cacheKey);
        if (!_connectivityService.isOnline && _healthRecords != null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // If online, fetch from network
      if (_connectivityService.isOnline) {
        await _fetchMyHealthRecordsFromNetwork(cacheKey);
      } else {
        // If offline and no cache, show appropriate message
        if (_healthRecords == null) {
          throw Exception(
              'No internet connection and no cached health records available. Please connect to the internet to view your health records.');
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching my health records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch health records for a specific patient UUID
  Future<void> fetchPatientHealthRecords(String patientUuid,
      {bool forceRefresh = false}) async {
    _isLoading = true;
    _error = '';
    _patientFound = false;
    notifyListeners();

    try {
      final cacheKey = 'patient_health_records_$patientUuid';

      // Check cache first
      if (!forceRefresh &&
          (!_connectivityService.isOnline ||
              await _cacheService.isCacheFresh())) {
        await _loadFromCache(cacheKey);
        if (!_connectivityService.isOnline && _healthRecords != null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Fetch from network if online
      if (_connectivityService.isOnline) {
        await _fetchPatientHealthRecordsFromNetwork(patientUuid, cacheKey);
      } else {
        if (_healthRecords == null) {
          throw Exception(
              'No internet connection and no cached data available.');
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching patient health records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search for a patient by name
  Future<Map<String, dynamic>?> searchPatient(
      String firstName, String lastName) async {
    try {
      if (!_connectivityService.isOnline) {
        throw Exception('No internet connection. Cannot search for patients.');
      }

      final response =
          await _healthRecordsService.searchPatient(firstName, lastName);
      return response;
    } catch (e) {
      debugPrint('Error searching for patient: $e');
      return null;
    }
  }

  /// Refresh health records (force network fetch)
  Future<void> refreshHealthRecords() async {
    await fetchMyHealthRecords(forceRefresh: true);
  }

  /// Clear all data
  void clearData() {
    _healthRecords = null;
    _error = '';
    _patientFound = false;
    _healthSummary = null;
    _lastSyncTime = null;
    notifyListeners();
  }

  /// Private method to fetch from network for authenticated user
  Future<void> _fetchMyHealthRecordsFromNetwork(String cacheKey) async {
    try {
      final response = await _healthRecordsService.getMyHealthRecords();

      _patientFound = response['patientFound'] == true;

      if (response['hasRecords'] == true && response['healthRecords'] != null) {
        _healthRecords =
            PatientHealthRecords.fromJson(response['healthRecords']);
        _generateHealthSummary();

        // Cache the data
        await _cacheService.cacheData(cacheKey, _healthRecords!.toJson(),
            expiry: const Duration(hours: 24));
        _lastSyncTime = DateTime.now();

        debugPrint(
            'Successfully fetched and cached health records for authenticated user');
      } else {
        _healthRecords = null;
        _error = response['message'] ?? 'No health records found';
        debugPrint('No health records found: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Failed to fetch health records from server: $e');
    }
  }

  /// Private method to fetch from network for specific patient
  Future<void> _fetchPatientHealthRecordsFromNetwork(
      String patientUuid, String cacheKey) async {
    try {
      final response =
          await _healthRecordsService.getPatientHealthRecords(patientUuid);

      if (response['hasRecords'] == true && response['healthRecords'] != null) {
        _healthRecords =
            PatientHealthRecords.fromJson(response['healthRecords']);
        _patientFound = true;
        _generateHealthSummary();

        // Cache the data
        await _cacheService.cacheData(cacheKey, _healthRecords!.toJson(),
            expiry: const Duration(hours: 24));
        _lastSyncTime = DateTime.now();

        debugPrint(
            'Successfully fetched and cached health records for patient: $patientUuid');
      } else {
        _healthRecords = null;
        _patientFound = false;
        _error =
            response['message'] ?? 'No health records found for this patient';
        debugPrint('No health records found for patient: $patientUuid');
      }
    } catch (e) {
      throw Exception('Failed to fetch patient health records from server: $e');
    }
  }

  /// Load data from cache
  Future<void> _loadFromCache(String cacheKey) async {
    try {
      final cachedData = await _cacheService.getCachedData(cacheKey);
      if (cachedData != null) {
        final jsonData = cachedData as Map<String, dynamic>;
        _healthRecords = PatientHealthRecords.fromJson(jsonData);
        _patientFound = true;
        _generateHealthSummary();

        debugPrint('Loaded health records from cache');
      }
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }
  }

  /// Generate health summary statistics
  void _generateHealthSummary() {
    if (_healthRecords != null) {
      _healthSummary = _healthRecordsService.getHealthSummary(_healthRecords!);
    }
  }

  /// Get observations by category
  Map<String, List<ObservationRecord>> getObservationsByCategory() {
    if (_healthRecords?.visits == null) return {};

    final Map<String, List<ObservationRecord>> categorizedObs = {};

    for (final visit in _healthRecords!.visits!) {
      for (final encounter in visit.encounters ?? []) {
        for (final obs in encounter.observations ?? []) {
          final category = obs.category ?? 'General';
          categorizedObs.putIfAbsent(category, () => []);
          categorizedObs[category]!.add(obs);
        }
      }
    }

    return categorizedObs;
  }

  /// Get all prescriptions
  List<OrderRecord> getAllPrescriptions() {
    if (_healthRecords?.visits == null) return [];

    final List<OrderRecord> allPrescriptions = [];

    for (final visit in _healthRecords!.visits!) {
      for (final encounter in visit.encounters ?? []) {
        for (final prescription in encounter.prescriptions ?? []) {
          allPrescriptions.add(prescription);
        }
      }
    }

    return allPrescriptions;
  }

  /// Get all diagnoses
  List<String> getAllDiagnoses() {
    if (_healthRecords?.visits == null) return [];

    final Set<String> allDiagnoses = {};

    for (final visit in _healthRecords!.visits!) {
      for (final encounter in visit.encounters ?? []) {
        for (final diagnosis in encounter.diagnoses ?? []) {
          allDiagnoses.add(diagnosis);
        }
      }
    }

    return allDiagnoses.toList();
  }
}
