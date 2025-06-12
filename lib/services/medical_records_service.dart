import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/encounter.dart';
import '../models/patient.dart';

class MedicalRecordsService {
  final ApiService _apiService;
  final AuthService _authService;

  MedicalRecordsService(this._apiService, this._authService);

  // NEW: Get comprehensive medical records by patient UUID (integrated with iCare)
  Future<Map<String, dynamic>> getMedicalRecordsByPatientUuid(String patientUuid) async {
    try {
      final response = await _apiService.get('medical-records/patient/$patientUuid');
      
      if (response != null && response is Map<String, dynamic>) {
        return response;
      } else {
        debugPrint('Unexpected response format for medical records: $response');
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching medical records by UUID: $e');
      throw Exception('Failed to fetch medical records: $e');
    }
  }

  // NEW: Get encounters from database by patient UUID (real hospital data)
  Future<Map<String, dynamic>> getEncountersByPatientUuid(String patientUuid) async {
    try {
      final response = await _apiService.get('encounters/db/patient/$patientUuid');
      
      if (response != null && response is Map<String, dynamic>) {
        return response;
      } else {
        debugPrint('Unexpected response format for encounters: $response');
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching encounters by patient UUID: $e');
      throw Exception('Failed to fetch encounters: $e');
    }
  }

  // NEW: Import encounters from iCare system for a patient
  Future<Map<String, dynamic>> importICareEncounters(String patientUuid) async {
    try {
      final response = await _apiService.post('encounters/import/icare/patient/$patientUuid', {});
      
      if (response != null && response is Map<String, dynamic>) {
        return response;
      } else {
        debugPrint('Unexpected response format for iCare import: $response');
        return {};
      }
    } catch (e) {
      debugPrint('Error importing iCare encounters: $e');
      throw Exception('Failed to import iCare encounters: $e');
    }
  }
  // ENHANCED: Get all encounters for the current authenticated user using real hospital data
  Future<List<Encounter>> getCurrentUserEncounters() async {
    try {
      // Get the current user from auth service
      final currentUser = _authService.currentUser;
      if (currentUser?.patientUuid == null) {
        throw Exception('No patient UUID found for current user. Please login again.');
      }

      debugPrint('Fetching encounters for current user with UUID: ${currentUser!.patientUuid}');
      
      // Use the new medical records endpoint that integrates with iCare
      final response = await getMedicalRecordsByPatientUuid(currentUser.patientUuid!);
      
      if (response['encounters'] != null && response['encounters'] is List) {
        final encounters = (response['encounters'] as List)
            .map((encounterData) => _parseEncounter(encounterData))
            .toList();
        
        debugPrint('Successfully loaded ${encounters.length} encounters for current user');
        return encounters;
      } else {
        debugPrint('No encounters found in response for current user');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching current user encounters: $e');
      throw Exception('Failed to fetch your medical records: $e');
    }
  }  // ENHANCED: Get encounter summary for current user  
  Future<Map<String, dynamic>> getCurrentUserEncounterSummary() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser?.patientUuid == null) {
        throw Exception('No patient UUID found for current user. Please login again.');
      }

      return await getEncountersByPatientUuid(currentUser!.patientUuid!);
    } catch (e) {
      debugPrint('Error fetching encounter summary: $e');
      throw Exception('Failed to fetch encounter summary: $e');
    }
  }

  // Helper method to parse encounter data from iCare integration
  Encounter _parseEncounter(Map<String, dynamic> encounterData) {
    return Encounter(
      id: encounterData['id']?.toString(),
      patientId: encounterData['patientId'] ?? 0,
      encounterType: encounterData['encounterType'] ?? 'Unknown',
      encounterDateTime: encounterData['encounterDateTime'] != null
          ? DateTime.tryParse(encounterData['encounterDateTime']) ?? DateTime.now()
          : DateTime.now(),
      location: encounterData['location'] ?? 'Unknown Location',
      provider: encounterData['provider'] ?? 'Unknown Provider',
      notes: encounterData['notes'] ?? '',
      diagnosis: encounterData['diagnosis'] ?? '',
      status: encounterData['status'] ?? 'COMPLETED',
      labResults: [],
      medications: [],
      diagnoses: [],
      treatments: [],
      vitalSigns: [],
    );
  }

  // LEGACY METHODS FOR BACKWARD COMPATIBILITY

  // Get all encounters for a patient (original database method)
  Future<List<Encounter>> getPatientEncounters(int patientId) async {
    try {
      final response = await _apiService.get('encounters/patient/$patientId');

      if (response is List) {
        return response
            .map((encounterData) => Encounter.fromMap(encounterData))
            .toList();
      } else {
        debugPrint('Unexpected response format for encounters: $response');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching patient encounters: $e');
      throw Exception('Failed to fetch patient encounters: $e');
    }
  }

  // Get encounters for a patient within a date range
  Future<List<Encounter>> getPatientEncountersByDateRange(
    int patientId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateString = startDate.toIso8601String();
      final endDateString = endDate.toIso8601String();

      final response = await _apiService.get(
          'encounters/patient/$patientId/dateRange?startDate=$startDateString&endDate=$endDateString');

      if (response is List) {
        return response
            .map((encounterData) => Encounter.fromMap(encounterData))
            .toList();
      } else {
        debugPrint('Unexpected response format for encounters: $response');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching patient encounters by date range: $e');
      throw Exception('Failed to fetch patient encounters by date range: $e');
    }
  }

  // Get a specific encounter by ID
  Future<Encounter?> getEncounterById(int encounterId) async {
    try {
      final response = await _apiService.get('encounters/$encounterId');

      if (response != null) {
        return Encounter.fromMap(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching encounter: $e');
      throw Exception('Failed to fetch encounter: $e');
    }
  }

  // Create a new encounter
  Future<Encounter> createEncounter(Encounter encounter) async {
    try {
      final response = await _apiService.post('encounters', encounter.toMap());

      if (response != null) {
        return Encounter.fromMap(response);
      } else {
        throw Exception('Failed to create encounter - no response data');
      }
    } catch (e) {
      debugPrint('Error creating encounter: $e');
      throw Exception('Failed to create encounter: $e');
    }
  }

  // Update an existing encounter
  Future<Encounter> updateEncounter(Encounter encounter) async {
    try {
      if (encounter.id == null) {
        throw Exception('Encounter ID is required for update');
      }

      final response = await _apiService.put(
          'encounters/${encounter.id}', encounter.toMap());

      if (response != null) {
        return Encounter.fromMap(response);
      } else {
        throw Exception('Failed to update encounter - no response data');
      }
    } catch (e) {
      debugPrint('Error updating encounter: $e');
      throw Exception('Failed to update encounter: $e');
    }
  }

  // Delete an encounter
  Future<void> deleteEncounter(int encounterId) async {
    try {
      await _apiService.delete('encounters/$encounterId');
    } catch (e) {
      debugPrint('Error deleting encounter: $e');
      throw Exception('Failed to delete encounter: $e');
    }
  }

  // Get patient information by ID
  Future<Patient?> getPatientById(int patientId) async {
    try {
      final response = await _apiService.get('patients/$patientId');

      if (response != null) {
        return Patient.fromMap(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching patient: $e');
      throw Exception('Failed to fetch patient: $e');
    }
  }

  // Get patient information by UUID
  Future<Patient?> getPatientByUuid(String patientUuid) async {
    try {
      // Since the backend doesn't have a direct endpoint for UUID lookup,
      // we'll need to search through patients or add this endpoint to backend
      final response = await _apiService.get('patients');

      if (response is List) {
        final patients = response
            .map((patientData) => Patient.fromMap(patientData))
            .toList();

        // Find patient by UUID
        for (Patient patient in patients) {
          if (patient.patientUuid == patientUuid) {
            return patient;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching patient by UUID: $e');
      throw Exception('Failed to fetch patient by UUID: $e');
    }
  }

  // Get all patients (for admin/staff use)
  Future<List<Patient>> getAllPatients() async {
    try {
      final response = await _apiService.get('patients');

      if (response is List) {
        return response
            .map((patientData) => Patient.fromMap(patientData))
            .toList();
      } else {
        debugPrint('Unexpected response format for patients: $response');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching patients: $e');
      throw Exception('Failed to fetch patients: $e');
    }
  }

  // NEW: Get encounters from database by patient UUID
  Future<List<Encounter>> getPatientEncountersFromDatabase(String patientUuid) async {
    try {
      final response = await _apiService.get('encounters/db/patient/$patientUuid');

      if (response != null && response is Map<String, dynamic>) {
        if (response['encounters'] != null && response['encounters'] is List) {
          return (response['encounters'] as List)
              .map((encounterData) => _parseEncounter(encounterData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching patient encounters from database: $e');
      throw Exception('Failed to fetch patient encounters from database: $e');
    }
  }

  // NEW: Get encounters from JSON file by patient UUID
  Future<List<Encounter>> getPatientEncountersFromFile(String patientUuid) async {
    try {
      final response = await _apiService.get('encounters/file/patient/$patientUuid');

      if (response != null && response['encounters'] is List) {
        final encountersData = response['encounters'] as List;
        return encountersData
            .map((encounterData) => _parseEncounter(encounterData))
            .toList();
      } else {
        debugPrint('No encounters found in file for patient UUID: $patientUuid');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching patient encounters from file: $e');
      throw Exception('Failed to fetch patient encounters from file: $e');
    }
  }

  // NEW: Check if patient has encounters in file
  Future<bool> hasEncountersInFile(String patientUuid) async {
    try {
      final response = await _apiService.get('encounters/file/patient/$patientUuid/exists');

      if (response != null && response['hasEncounters'] is bool) {
        return response['hasEncounters'] as bool;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking encounters in file: $e');
      return false;
    }
  }

  // NEW: Get encounters summary from file
  Future<Map<String, dynamic>?> getPatientEncountersSummaryFromFile(String patientUuid) async {
    try {
      final response = await _apiService.get('encounters/file/patient/$patientUuid/summary');
      return response;
    } catch (e) {
      debugPrint('Error fetching encounters summary from file: $e');
      return null;
    }
  }

  // NEW: Get all encounters from file (for admin/testing)
  Future<List<Encounter>> getAllEncountersFromFile() async {
    try {
      final response = await _apiService.get('encounters/file/all');

      if (response != null && response['encounters'] is List) {
        final encountersData = response['encounters'] as List;
        return encountersData
            .map((encounterData) => _parseEncounter(encounterData))
            .toList();
      } else {
        debugPrint('No encounters found in file');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching all encounters from file: $e');
      throw Exception('Failed to fetch all encounters from file: $e');
    }
  }

  // Convert encounters to health records for backward compatibility
  List<dynamic> convertEncountersToHealthRecords(List<Encounter> encounters) {
    return encounters.map((encounter) {
      return {
        'id': encounter.id.toString(),
        'title': _getEncounterTitle(encounter),
        'date': encounter.encounterDateTime.toIso8601String(),
        'provider': encounter.provider,
        'type': encounter.encounterType,
        'description': encounter.notes,
        'diagnosis': encounter.diagnosis,
        'status': encounter.status,
        'location': encounter.location,
        'attachments': <String>[],
        'labResults': encounter.labResults,
        'medications': encounter.medications,
        'diagnoses': encounter.diagnoses,
        'treatments': encounter.treatments,
        'vitalSigns': encounter.vitalSigns,
        'observations': encounter.observations,
      };
    }).toList();
  }

  // Helper method to generate a user-friendly title for encounters
  String _getEncounterTitle(Encounter encounter) {
    switch (encounter.encounterType.toUpperCase()) {
      case 'REGISTRATION':
        return 'Patient Registration';
      case 'CONSULTATION':
        return 'Medical Consultation';
      case 'VISIT NOTE':
        return 'Clinical Visit';
      case 'DISPENSING':
        return 'Medication Dispensing';
      case 'EMERGENCY':
        return 'Emergency Department Visit';
      case 'ADMISSION':
        return 'Hospital Admission';
      case 'LABORATORY':
        return 'Laboratory Tests';
      case 'RADIOLOGY':
        return 'Radiology Exam';
      case 'VACCINATION':
        return 'Vaccination';
      case 'DENTAL':
        return 'Dental Checkup';
      case 'PREVENTIVE':
        return 'Preventive Care Visit';
      case 'SPECIALIST':
        return 'Specialist Consultation';
      case 'URGENT_CARE':
        return 'Urgent Care Visit';
      default:
        return encounter.encounterType
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) =>
                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }
}
