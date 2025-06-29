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

  // Enhanced health records methods
  List<VisitRecord> _enhancedVisits = [];
  PatientHealthRecords? _enhancedHealthRecords;

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
  List<VisitRecord> get enhancedVisits => _enhancedVisits;
  PatientHealthRecords? get enhancedHealthRecords => _enhancedHealthRecords;

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

  /// Fetch enhanced visits using the new backend endpoints
  Future<void> fetchEnhancedVisits() async {
    if (_isOffline) {
      _error = 'Cannot fetch enhanced visits while offline';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final visits = await _healthRecordsService.getMyEnhancedVisits();
      _enhancedVisits = visits;
      _patientFound = visits.isNotEmpty;
      _lastSyncTime = DateTime.now();
      _error = '';
      // Cache the enhanced visits
      await _cacheService.cacheData(
          'enhanced_visits', visits.map((v) => v.toJson()).toList(),
          expiry: const Duration(hours: 24));

      debugPrint('Successfully fetched ${visits.length} enhanced visits');
    } catch (e) {
      _error = 'Failed to fetch enhanced visits: $e';
      debugPrint('Error fetching enhanced visits: $e');

      // Try to load from cache
      await _loadEnhancedVisitsFromCache();
    }
    _setLoading(false);
  }

  /// Fetch enhanced health records (including demographics and visits)
  Future<void> fetchEnhancedHealthRecords() async {
    if (_isOffline) {
      _error = 'Cannot fetch enhanced health records while offline';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final healthRecords =
          await _healthRecordsService.getMyEnhancedHealthRecords();
      _enhancedHealthRecords = healthRecords;

      if (healthRecords != null) {
        _enhancedVisits = healthRecords.visits ?? [];
        _patientFound = true;
        _lastSyncTime = DateTime.now();
        _error = '';
        // Cache the enhanced health records
        await _cacheService.cacheData(
            'enhanced_health_records', healthRecords.toJson(),
            expiry: const Duration(hours: 24));

        debugPrint('Successfully fetched enhanced health records');
      } else {
        _patientFound = false;
        _error = 'No health records found';
      }
    } catch (e) {
      _error = 'Failed to fetch enhanced health records: $e';
      debugPrint('Error fetching enhanced health records: $e');

      // Try to load from cache
      await _loadEnhancedHealthRecordsFromCache();
    }
    _setLoading(false);
  }

  /// Load enhanced visits from cache
  Future<void> _loadEnhancedVisitsFromCache() async {
    try {
      final cachedData = await _cacheService.getCachedData('enhanced_visits');
      if (cachedData != null && cachedData is List) {
        _enhancedVisits = cachedData
            .map((visitData) => VisitRecord.fromJson(visitData))
            .toList();
        debugPrint(
            'Loaded ${_enhancedVisits.length} enhanced visits from cache');
      }
    } catch (e) {
      debugPrint('Error loading enhanced visits from cache: $e');
    }
  }

  /// Load enhanced health records from cache
  Future<void> _loadEnhancedHealthRecordsFromCache() async {
    try {
      final cachedData =
          await _cacheService.getCachedData('enhanced_health_records');
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        _enhancedHealthRecords = PatientHealthRecords.fromJson(cachedData);
        _enhancedVisits = _enhancedHealthRecords?.visits ?? [];
        debugPrint('Loaded enhanced health records from cache');
      }
    } catch (e) {
      debugPrint('Error loading enhanced health records from cache: $e');
    }
  }

  /// Get medications from enhanced visits
  List<Map<String, dynamic>> getEnhancedMedications() {
    final allMedications = <Map<String, dynamic>>[];

    for (final visit in _enhancedVisits) {
      allMedications
          .addAll(_healthRecordsService.extractMedicationsFromVisit(visit));
    }

    return allMedications;
  }

  /// Get diagnoses from enhanced visits
  List<Map<String, dynamic>> getEnhancedDiagnoses() {
    final allDiagnoses = <Map<String, dynamic>>[];

    for (final visit in _enhancedVisits) {
      allDiagnoses
          .addAll(_healthRecordsService.extractDiagnosesFromVisit(visit));
    }

    return allDiagnoses;
  }

  /// Get observations from enhanced visits
  List<Map<String, dynamic>> getEnhancedObservations() {
    final allObservations = <Map<String, dynamic>>[];

    for (final visit in _enhancedVisits) {
      allObservations
          .addAll(_healthRecordsService.extractObservationsFromVisit(visit));
    }

    return allObservations;
  }

  /// Private method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
