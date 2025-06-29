import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/patient_health_records.dart';

class HealthRecordsService {
  final ApiService _apiService;
  final AuthService _authService;

  HealthRecordsService(this._apiService, this._authService);

  /// Get comprehensive health records for the authenticated user
  Future<Map<String, dynamic>> getMyHealthRecords() async {
    try {
      debugPrint('Fetching health records for authenticated user');

      final response = await _apiService.get('health-records/my-records');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Health records response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from health records API');
      }
    } catch (e) {
      debugPrint('Error fetching my health records: $e');
      throw Exception('Failed to fetch health records: $e');
    }
  }

  /// Get health records for a specific patient UUID
  Future<Map<String, dynamic>> getPatientHealthRecords(
      String patientUuid) async {
    try {
      debugPrint('Fetching health records for patient: $patientUuid');

      final response =
          await _apiService.get('health-records/patient/$patientUuid');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Patient health records response: $response');
        return response;
      } else {
        throw Exception(
            'Invalid response format from patient health records API');
      }
    } catch (e) {
      debugPrint('Error fetching patient health records: $e');
      throw Exception('Failed to fetch patient health records: $e');
    }
  }

  /// Search for a patient by name in iCare
  Future<Map<String, dynamic>> searchPatient(
      String firstName, String lastName) async {
    try {
      debugPrint('Searching for patient: $firstName $lastName');

      final response = await _apiService.get(
          'health-records/search-patient?firstName=$firstName&lastName=$lastName');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Patient search response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from patient search API');
      }
    } catch (e) {
      debugPrint('Error searching for patient: $e');
      throw Exception('Failed to search for patient: $e');
    }
  }

  /// Test connection to iCare system
  Future<Map<String, dynamic>> testConnection() async {
    try {
      debugPrint('Testing connection to iCare system');

      final response = await _apiService.get('health-records/test-connection');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Connection test response: $response');
        return response;
      } else {
        throw Exception('Invalid response format from connection test API');
      }
    } catch (e) {
      debugPrint('Error testing connection: $e');
      throw Exception('Failed to test connection: $e');
    }
  }

  /// Get patient visits directly from iCare
  Future<List<Map<String, dynamic>>> getPatientVisits(
      String patientUuid) async {
    try {
      debugPrint('Fetching visits for patient: $patientUuid');

      final response =
          await _apiService.get('icare/patients/$patientUuid/visits');

      if (response != null && response is List) {
        debugPrint('Patient visits response: Found ${response.length} visits');
        return List<Map<String, dynamic>>.from(response);
      } else {
        throw Exception('Invalid response format from visits API');
      }
    } catch (e) {
      debugPrint('Error fetching patient visits: $e');
      throw Exception('Failed to fetch patient visits: $e');
    }
  }

  /// Get comprehensive health records from iCare directly
  Future<PatientHealthRecords?> getComprehensiveHealthRecords(
      String patientUuid) async {
    try {
      debugPrint(
          'Fetching comprehensive health records for patient: $patientUuid');

      final response =
          await _apiService.get('icare/patients/$patientUuid/health-records');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Comprehensive health records response received');
        return PatientHealthRecords.fromJson(response);
      } else {
        debugPrint('No health records found for patient: $patientUuid');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching comprehensive health records: $e');
      throw Exception('Failed to fetch comprehensive health records: $e');
    }
  }

  /// Parse health records response and extract PatientHealthRecords
  PatientHealthRecords? parseHealthRecordsResponse(
      Map<String, dynamic> response) {
    try {
      if (response['hasRecords'] == true && response['healthRecords'] != null) {
        return PatientHealthRecords.fromJson(response['healthRecords']);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing health records response: $e');
      return null;
    }
  }

  /// Get summary statistics from health records
  Map<String, dynamic> getHealthSummary(PatientHealthRecords healthRecords) {
    final visits = healthRecords.visits ?? [];
    final allEncounters =
        visits.expand((visit) => visit.encounters ?? []).toList();

    // Count by encounter type
    final encounterTypes = <String, int>{};
    for (final encounter in allEncounters) {
      final type = encounter.encounterType ?? 'Unknown';
      encounterTypes[type] = (encounterTypes[type] ?? 0) + 1;
    }

    // Count observations by category
    final observationCategories = <String, int>{};
    for (final encounter in allEncounters) {
      for (final obs in encounter.observations ?? []) {
        final category = obs.category ?? 'General';
        observationCategories[category] =
            (observationCategories[category] ?? 0) + 1;
      }
    } // Count prescriptions
    var totalPrescriptions = 0;
    for (final encounter in allEncounters) {
      totalPrescriptions += (encounter.prescriptions?.length ?? 0) as int;
    }

    // Get latest visit date
    final sortedVisits = List<VisitRecord>.from(visits);
    sortedVisits.sort((a, b) {
      final dateA = DateTime.tryParse(a.startDate ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.startDate ?? '') ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    return {
      'totalVisits': visits.length,
      'totalEncounters': allEncounters.length,
      'totalPrescriptions': totalPrescriptions,
      'encounterTypes': encounterTypes,
      'observationCategories': observationCategories,
      'latestVisitDate':
          sortedVisits.isNotEmpty ? sortedVisits.first.startDate : null,
      'patientName': healthRecords.demographics?.fullName,
      'patientAge': healthRecords.demographics?.age,
      'patientGender': healthRecords.demographics?.gender,
    };
  }

  /// Get enhanced visits data for the authenticated user
  Future<List<VisitRecord>> getMyEnhancedVisits() async {
    try {
      debugPrint('Fetching enhanced visits for authenticated user');

      final response =
          await _apiService.get('health-records/my-visits-enhanced');

      if (response != null && response is List) {
        debugPrint('Enhanced visits response: Found ${response.length} visits');
        return response.map((visit) => VisitRecord.fromJson(visit)).toList();
      } else if (response != null && response is Map<String, dynamic>) {
        // Handle case where response is wrapped in an object
        final visits = response['visits'] as List?;
        if (visits != null) {
          return visits.map((visit) => VisitRecord.fromJson(visit)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching enhanced visits: $e');
      throw Exception('Failed to fetch enhanced visits: $e');
    }
  }

  /// Get enhanced visit data for a specific patient (admin/provider use)
  Future<List<VisitRecord>> getPatientEnhancedVisits(String patientUuid) async {
    try {
      debugPrint('Fetching enhanced visits for patient: $patientUuid');

      final response = await _apiService
          .get('health-records/patient/$patientUuid/visits-enhanced');

      if (response != null && response is List) {
        debugPrint(
            'Patient enhanced visits response: Found ${response.length} visits');
        return response.map((visit) => VisitRecord.fromJson(visit)).toList();
      } else if (response != null && response is Map<String, dynamic>) {
        // Handle case where response is wrapped in an object
        final visits = response['visits'] as List?;
        if (visits != null) {
          return visits.map((visit) => VisitRecord.fromJson(visit)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching patient enhanced visits: $e');
      throw Exception('Failed to fetch patient enhanced visits: $e');
    }
  }

  /// Get enhanced health records including demographics and visits
  Future<PatientHealthRecords?> getMyEnhancedHealthRecords() async {
    try {
      debugPrint('Fetching enhanced health records for authenticated user');

      final response =
          await _apiService.get('health-records/my-enhanced-records');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Enhanced health records response received');
        return PatientHealthRecords.fromJson(response);
      } else {
        debugPrint('No enhanced health records found');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching enhanced health records: $e');
      throw Exception('Failed to fetch enhanced health records: $e');
    }
  }

  /// Extract medications from visit encounters with enhanced details
  List<Map<String, dynamic>> extractMedicationsFromVisit(VisitRecord visit) {
    final medications = <Map<String, dynamic>>[];

    for (final encounter in visit.encounters ?? []) {
      for (final prescription in encounter.prescriptions ?? []) {
        medications.add({
          'name': prescription.conceptDisplay ??
              prescription.concept ??
              'Unknown Medication',
          'dosage': prescription.dosage,
          'frequency': prescription.frequency,
          'duration': prescription.duration,
          'instructions': prescription.instructions,
          'dateActivated': prescription.dateActivated,
          'urgency': prescription.urgency,
          'action': prescription.action,
          'orderType': prescription.orderType,
          'encounterType': encounter.encounterType,
          'encounterDate': encounter.encounterDate ?? encounter.startDatetime,
          'provider': encounter.provider,
          'uuid': prescription.uuid,
        });
      }
    }

    return medications;
  }

  /// Extract diagnoses from visit encounters
  List<Map<String, dynamic>> extractDiagnosesFromVisit(VisitRecord visit) {
    final diagnoses = <Map<String, dynamic>>[];

    for (final encounter in visit.encounters ?? []) {
      for (final diagnosis in encounter.diagnoses ?? []) {
        diagnoses.add({
          'diagnosis': diagnosis,
          'encounterType': encounter.encounterType,
          'encounterDate': encounter.encounterDate ?? encounter.startDatetime,
          'provider': encounter.provider,
          'encounterUuid': encounter.encounterUuid,
        });
      }
    }

    return diagnoses;
  }

  /// Extract observations from visit encounters with enhanced details
  List<Map<String, dynamic>> extractObservationsFromVisit(VisitRecord visit) {
    final observations = <Map<String, dynamic>>[];

    for (final encounter in visit.encounters ?? []) {
      for (final obs in encounter.observations ?? []) {
        observations.add({
          'concept': obs.conceptDisplay ?? obs.concept ?? 'Unknown Observation',
          'value': obs.value,
          'valueDisplay': obs.valueDisplay,
          'units': obs.units,
          'normalRange': obs.normalRange,
          'category': obs.category,
          'obsDate': obs.obsDate,
          'comment': obs.comment,
          'encounterType': encounter.encounterType,
          'encounterDate': encounter.encounterDate ?? encounter.startDatetime,
          'provider': encounter.provider,
          'uuid': obs.uuid,
        });
      }
    }

    return observations;
  }
}
