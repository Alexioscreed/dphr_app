import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/health_record.dart';
import '../models/encounter.dart';
import '../models/patient.dart';
import '../services/medical_records_service.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/cache_service.dart';

class HealthRecordProvider with ChangeNotifier {
  final MedicalRecordsService _medicalRecordsService;
  final AuthService _authService;
  final ConnectivityService _connectivityService;
  final CacheService _cacheService;

  List<HealthRecord> _healthRecords = [];
  List<Encounter> _encounters = [];
  Patient? _currentPatient;
  bool _isLoading = false;
  String _error = '';
  bool _isOffline = false;
  DateTime? _lastSyncTime;
  HealthRecordProvider(
    this._medicalRecordsService,
    this._authService,
    this._connectivityService,
    this._cacheService,
  ) {
    _connectivityService.addListener(_onConnectivityChanged);
    _isOffline = !_connectivityService.isOnline;
  }
  List<HealthRecord> get healthRecords => [..._healthRecords];
  List<Encounter> get encounters => [..._encounters];
  Patient? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isOffline => _isOffline;
  DateTime? get lastSyncTime => _lastSyncTime;
  void _onConnectivityChanged() {
    final wasOffline = _isOffline;
    _isOffline = !_connectivityService.isOnline;

    if (wasOffline && !_isOffline) {
      // Just came back online, try to sync
      debugPrint('Connectivity restored, attempting to sync data');
      fetchHealthRecords();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  } // Fetch health records from backend with offline-first approach

  Future<void> fetchHealthRecords({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Get current user
      final currentUser = _authService.currentUser;
      debugPrint('Current user: ${currentUser?.toJson()}');
      debugPrint('Patient UUID: ${currentUser?.patientUuid}');

      if (currentUser?.patientUuid == null) {
        throw Exception('No patient UUID found. Please login again.');
      }

      final patientUuid = currentUser!.patientUuid!;

      // Check if we should load from cache first
      if (!forceRefresh &&
          (!_connectivityService.isOnline ||
              await _cacheService.isCacheFresh())) {
        await _loadFromCache(patientUuid);

        // If offline and cache loaded successfully, stop here
        if (!_connectivityService.isOnline &&
            (_healthRecords.isNotEmpty || _encounters.isNotEmpty)) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // If online, fetch from network and update cache
      if (_connectivityService.isOnline) {
        await _fetchFromNetwork(patientUuid);
      } else {
        // If offline and no cache, show appropriate message
        if (_healthRecords.isEmpty && _encounters.isEmpty) {
          throw Exception(
              'No internet connection and no cached data available. Please connect to the internet to view your health records.');
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching health records: $e');

      // If there's an error and we're online, try to load from cache as fallback
      if (_connectivityService.isOnline && !forceRefresh) {
        try {
          final currentUser = _authService.currentUser;
          if (currentUser?.patientUuid != null) {
            await _loadFromCache(currentUser!.patientUuid!);
            _error =
                'Failed to fetch latest data. Showing cached data. $_error';
          }
        } catch (cacheError) {
          debugPrint('Failed to load from cache: $cacheError');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromCache(String patientUuid) async {
    debugPrint('Loading health records from cache for patient: $patientUuid');

    // Load cached data
    final cachedHealthRecords = await _cacheService.getCachedHealthRecords();
    final cachedEncounters = await _cacheService.getCachedEncounters();
    final cachedPatient =
        await _cacheService.getCachedData('patient_$patientUuid');

    if (cachedHealthRecords != null) {
      _healthRecords = cachedHealthRecords;
      debugPrint('Loaded ${_healthRecords.length} health records from cache');
    }

    if (cachedEncounters != null) {
      _encounters = cachedEncounters;
      debugPrint('Loaded ${_encounters.length} encounters from cache');
    }
    if (cachedPatient != null) {
      try {
        // If cachedPatient is a string, parse it; if it's already a Map, use it directly
        final patientData =
            cachedPatient is String ? jsonDecode(cachedPatient) : cachedPatient;
        _currentPatient = Patient.fromJson(patientData);
        debugPrint('Loaded patient data from cache');
      } catch (e) {
        debugPrint('Error parsing cached patient data: $e');
        // If there's an error parsing, clear the corrupted cache
        await _cacheService.clearCache('patient_$patientUuid');
      }
    }

    _lastSyncTime = await _cacheService.getLastSyncTime();
  }
  Future<void> _fetchFromNetwork(String patientUuid) async {
    debugPrint(
        'Fetching health records from network for patient: $patientUuid');

    // NEW: Use integrated medical records service to get comprehensive data
    try {
      // Get medical records using the new integrated endpoint
      final medicalRecordsResponse = await _medicalRecordsService.getMedicalRecordsByPatientUuid(patientUuid);
      
      if (medicalRecordsResponse['patient'] != null) {
        // Parse patient data from integrated response
        final patientData = medicalRecordsResponse['patient'];        _currentPatient = Patient(
          id: patientData['id'] != null ? int.tryParse(patientData['id'].toString()) : null,
          patientUuid: patientData['patientUuid'] ?? patientUuid,
          mrn: patientData['mrn'] ?? 'Unknown',
          firstName: patientData['firstName'] ?? '',
          lastName: patientData['lastName'] ?? '',
          email: patientData['email'] ?? '',
          phoneNumber: patientData['phoneNumber'],
          dateOfBirth: patientData['dateOfBirth'] != null
              ? DateTime.tryParse(patientData['dateOfBirth'])
              : null,
          gender: patientData['gender'],
          bloodType: patientData['bloodType'],
          address: patientData['address'],
          allergies: patientData['allergies'],
        );
        debugPrint('Loaded patient data from integrated medical records: ${_currentPatient?.firstName} ${_currentPatient?.lastName}');
      }
      
      // Get encounters using the new integrated service
      _encounters = await _medicalRecordsService.getCurrentUserEncounters();
      debugPrint('Loaded ${_encounters.length} encounters from integrated medical records service');
      
    } catch (e) {
      debugPrint('Error fetching from integrated medical records, falling back to legacy methods: $e');
      
      // Fallback to legacy approach
      _currentPatient = await _medicalRecordsService.getPatientByUuid(patientUuid);
    }

    // If patient not found in database, create a placeholder from auth data
    if (_currentPatient == null) {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        _currentPatient = Patient(
          id: null, // No database ID yet
          patientUuid: patientUuid,
          mrn: currentUser.mrn,
          firstName: currentUser.name.split(' ').first,
          lastName: currentUser.name.split(' ').length > 1
              ? currentUser.name.split(' ').last
              : '',
          email: currentUser.email,
          phoneNumber: currentUser.phone,
          dateOfBirth: currentUser.dateOfBirth != null
              ? DateTime.tryParse(currentUser.dateOfBirth!)
              : null,
          gender: currentUser.gender,
          bloodType: currentUser.bloodType,
          address: currentUser.address,
          allergies: currentUser.allergies?.join(', '),
        );
      } else {
        throw Exception('Patient not found and no auth data available');
      }
    }

    // Cache patient data
    await _cacheService.cacheData(
        'patient_$patientUuid',
        _currentPatient!
            .toJson()); // Get encounters from database using patientUuid (UPDATED approach)
    debugPrint(
        'Fetching encounters from database for patientUuid: $patientUuid');
    try {
      _encounters = await _medicalRecordsService
          .getPatientEncountersFromDatabase(patientUuid);
      debugPrint('Loaded ${_encounters.length} encounters from database');
    } catch (e) {
      debugPrint('Error fetching from database, falling back to file: $e');
      // Fallback to file-based encounters if database fails
      final hasFileEncounters =
          await _medicalRecordsService.hasEncountersInFile(patientUuid);

      if (hasFileEncounters) {
        debugPrint('Found encounters in file, fetching as fallback...');
        _encounters = await _medicalRecordsService
            .getPatientEncountersFromFile(patientUuid);
        debugPrint(
            'Loaded ${_encounters.length} encounters from file (fallback)');
      } else {
        debugPrint(
            'No encounters found in database or file for patientUuid: $patientUuid');
        // If patient exists in database, try getting encounters by patient ID
        if (_currentPatient!.id != null) {
          _encounters = await _medicalRecordsService
              .getPatientEncounters(_currentPatient!.id!);
          debugPrint(
              'Loaded ${_encounters.length} encounters using patient ID');
        } else {
          _encounters = [];
          debugPrint(
              'No encounters found - patient may not have any encounter records yet');
        }
      }
    }

    // Convert encounters to health records for backward compatibility
    final healthRecordData =
        _medicalRecordsService.convertEncountersToHealthRecords(_encounters);

    _healthRecords = healthRecordData.map((recordData) {
      return HealthRecord(
        id: recordData['id'],
        title: recordData['title'],
        date: DateTime.parse(recordData['date']),
        provider: recordData['provider'],
        type: recordData['type'],
        description: recordData['description'],
        attachments: List<String>.from(recordData['attachments']),
      );
    }).toList();

    // Cache the fetched data
    await _cacheService.cacheHealthRecords(_healthRecords);
    await _cacheService.cacheEncounters(_encounters);

    _lastSyncTime = DateTime.now();
    debugPrint(
        'Successfully fetched and cached ${_healthRecords.length} health records and ${_encounters.length} encounters');
  }

  // Force refresh data from network
  Future<void> refreshHealthRecords() async {
    if (!_connectivityService.isOnline) {
      _error = 'No internet connection. Cannot refresh data.';
      notifyListeners();
      return;
    }

    await fetchHealthRecords(forceRefresh: true);
  }

  // Clear cached data
  Future<void> clearCache() async {
    final currentUser = _authService.currentUser;
    if (currentUser?.patientUuid != null) {
      final patientUuid = currentUser!.patientUuid!;
      await _cacheService.clearHealthRecordsCache();
      await _cacheService.clearCache('patient_$patientUuid');

      _healthRecords.clear();
      _encounters.clear();
      _currentPatient = null;
      _lastSyncTime = null;
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

  // Get encounter by ID
  Encounter? getEncounterById(dynamic id) {
    try {
      return _encounters.firstWhere((encounter) => encounter.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch encounters by date range
  Future<void> fetchEncountersByDateRange(
      DateTime startDate, DateTime endDate) async {
    if (_currentPatient?.id == null) {
      _error = 'Patient ID not found';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _encounters =
          await _medicalRecordsService.getPatientEncountersByDateRange(
        _currentPatient!.id!,
        startDate,
        endDate,
      );

      // Convert to health records
      final healthRecordData =
          _medicalRecordsService.convertEncountersToHealthRecords(_encounters);

      _healthRecords = healthRecordData.map((recordData) {
        return HealthRecord(
          id: recordData['id'],
          title: recordData['title'],
          date: DateTime.parse(recordData['date']),
          provider: recordData['provider'],
          type: recordData['type'],
          description: recordData['description'],
          attachments: List<String>.from(recordData['attachments']),
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add health record
  Future<void> addHealthRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, just add to local list
      // In the future, this would create an encounter in the backend
      _healthRecords.add(record);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new encounter
  Future<void> createEncounter(Encounter encounter) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newEncounter =
          await _medicalRecordsService.createEncounter(encounter);
      _encounters.add(newEncounter);

      // Refresh health records
      await fetchHealthRecords();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an encounter
  Future<void> updateEncounter(Encounter encounter) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedEncounter =
          await _medicalRecordsService.updateEncounter(encounter);

      // Update in local list
      final index = _encounters.indexWhere((e) => e.id == updatedEncounter.id);
      if (index != -1) {
        _encounters[index] = updatedEncounter;
      }

      // Refresh health records
      await fetchHealthRecords();

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
