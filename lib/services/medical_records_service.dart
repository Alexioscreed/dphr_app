import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/encounter.dart';
import '../models/patient.dart';

class MedicalRecordsService {
  final ApiService _apiService;

  MedicalRecordsService(this._apiService);

  // Get all encounters for a patient
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
        'attachments':
            <String>[], // Will be populated when file attachments are implemented
        // Enhanced medical data
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
