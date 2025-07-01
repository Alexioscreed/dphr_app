import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/concept.dart';
import '../models/encounter.dart';

class ConceptService {
  final ApiService _apiService;

  ConceptService(this._apiService);

  /// Search for concepts by term and source
  Future<List<Concept>> searchConcepts({
    String? term,
    String? source,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String>[];
      if (term != null && term.isNotEmpty) {
        queryParams.add('term=$term');
      }
      if (source != null && source.isNotEmpty) {
        queryParams.add('source=${Uri.encodeComponent(source)}');
      }
      queryParams.add('limit=$limit');

      final endpoint = 'concepts/search?${queryParams.join('&')}';
      debugPrint('Searching concepts with endpoint: $endpoint');

      final response = await _apiService.get(endpoint);

      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true) {
        final data = response['data'] as List?;
        if (data != null) {
          return data.map((item) => Concept.fromJson(item)).toList();
        }
      }

      debugPrint('No concepts found or invalid response format');
      return [];
    } catch (e) {
      debugPrint('Error searching concepts: $e');
      throw Exception('Failed to search concepts: $e');
    }
  }

  /// Get a specific concept by UUID
  Future<Concept?> getConceptByUuid(String conceptUuid) async {
    try {
      debugPrint('Fetching concept with UUID: $conceptUuid');

      final response = await _apiService.get('concepts/$conceptUuid');

      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          return Concept.fromJson(data);
        }
      }

      debugPrint('Concept not found or invalid response format');
      return null;
    } catch (e) {
      debugPrint('Error fetching concept: $e');
      throw Exception('Failed to fetch concept: $e');
    }
  }

  /// Get encounters for a patient with concept filtering
  Future<List<Encounter>> getPatientEncountersWithConcept({
    required String patientUuid,
    String? conceptUuid,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = <String>[];
      if (conceptUuid != null && conceptUuid.isNotEmpty) {
        queryParams.add('conceptUuid=$conceptUuid');
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams.add('fromDate=$fromDate');
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams.add('toDate=$toDate');
      }

      final endpoint = queryParams.isNotEmpty
          ? 'encounters/icare/patient/$patientUuid?${queryParams.join('&')}'
          : 'encounters/icare/patient/$patientUuid';

      debugPrint('Fetching encounters with concept filter: $endpoint');

      final response = await _apiService.get(endpoint);

      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true) {
        final data = response['data'] as List?;
        if (data != null) {
          return data.map((item) => _parseEncounter(item)).toList();
        }
      }

      debugPrint('No encounters found or invalid response format');
      return [];
    } catch (e) {
      debugPrint('Error fetching encounters with concept: $e');
      throw Exception('Failed to fetch encounters with concept: $e');
    }
  }

  /// Search for blood type concepts specifically
  Future<List<Concept>> searchBloodTypeConcepts() async {
    return searchConcepts(
      term: '38341003', // SNOMED CT code for blood type
      source: 'SNOMED CT',
      limit: 5,
    );
  }

  /// Search for vital sign concepts
  Future<List<Concept>> searchVitalSignConcepts() async {
    return searchConcepts(
      term: '', // Get all available concepts for now
      limit: 20,
    );
  }

  /// Get patient's medical records with concept filtering
  Future<List<Encounter>> getPatientMedicalRecords({
    required String patientUuid,
    String? conceptUuid,
    String? fromDate,
  }) async {
    return getPatientEncountersWithConcept(
      patientUuid: patientUuid,
      conceptUuid: conceptUuid,
      fromDate: fromDate ?? '2016-10-08',
    );
  }

  /// Helper method to parse encounter data
  Encounter _parseEncounter(Map<String, dynamic> data) {
    return Encounter(
      id: data['id']?.toString(),
      patientId: int.tryParse(data['patientId']?.toString() ?? '0') ?? 0,
      doctorId: data['doctorId'] != null
          ? int.tryParse(data['doctorId'].toString())
          : null,
      encounterType: data['encounterType']?.toString() ?? 'Unknown',
      encounterDateTime:
          data['encounterDate'] != null || data['encounterDateTime'] != null
              ? DateTime.tryParse(
                      data['encounterDate'] ?? data['encounterDateTime']) ??
                  DateTime.now()
              : DateTime.now(),
      location: data['location']?.toString() ?? 'Unknown',
      provider: data['provider']?.toString() ?? 'Unknown',
      notes: data['notes']?.toString() ?? '',
      diagnosis: data['diagnosis']?.toString() ?? '',
      chiefComplaint: data['chiefComplaint']?.toString(),
      status: data['status']?.toString() ?? 'Unknown',
      observations: [], // TODO: Parse observations if needed
      vitalSigns: [], // TODO: Parse vital signs if needed
      labResults: [], // TODO: Parse lab results if needed
      medications: [], // TODO: Parse medications if needed
      diagnoses: [], // TODO: Parse diagnoses if needed
      treatments: [], // TODO: Parse treatments if needed
    );
  }
}
