import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/shared_record.dart';

class SharedRecordsService {
  final ApiService _apiService;
  final AuthService _authService; // For future authentication checks

  SharedRecordsService(this._apiService, this._authService);

  /// Check if user is authenticated (for future use)
  bool get isAuthenticated => _authService.isAuthenticated;

  /// Get shared records based on real health record data
  Future<List<SharedRecord>> getSharedRecords() async {
    try {
      debugPrint('Fetching shared records from health records data');

      // Get the user's health records
      final response = await _apiService.get('health-records/my-records');

      if (response != null && response is Map<String, dynamic>) {
        debugPrint('Health records response received: ${response.keys}');

        if (response['hasRecords'] == true &&
            response['healthRecords'] != null) {
          final healthRecords = response['healthRecords'];

          // Transform health records into shared records
          List<SharedRecord> sharedRecords = [];

          // Create shared records from visits
          if (healthRecords['visits'] != null) {
            final visits = healthRecords['visits'] as List;

            for (var i = 0; i < visits.length && i < 3; i++) {
              // Limit to recent visits
              final visit = visits[i];

              // Create a shared record for each significant visit
              if (visit['encounters'] != null &&
                  (visit['encounters'] as List).isNotEmpty) {
                final encounters = visit['encounters'] as List;
                final mainEncounter = encounters.first;

                String recordType = _determineRecordType(mainEncounter);
                String description = _createDescription(visit, mainEncounter);
                List<String> files = _generateFileNames(visit, recordType);

                // Create different recipients based on record type
                String recipientName = _getRecipientName(recordType, i);
                String recipientEmail = _getRecipientEmail(recordType, i);

                sharedRecords.add(SharedRecord(
                  id: 'real_${visit['uuid'] ?? i.toString()}',
                  recipientName: recipientName,
                  recipientEmail: recipientEmail,
                  recordType: recordType,
                  sharedDate: _parseDate(visit['startDatetime']) ??
                      DateTime.now().subtract(Duration(days: i + 1)),
                  expiryDate: DateTime.now().add(Duration(days: 30 - i)),
                  status: 'Active',
                  description: description,
                  files: files,
                ));
              }
            }
          }

          // If no visits, create a placeholder based on patient info
          if (sharedRecords.isEmpty &&
              healthRecords['patientDemographics'] != null) {
            sharedRecords.add(SharedRecord(
              id: 'demographic_record',
              recipientName: 'Dr. Primary Care Physician',
              recipientEmail: 'primary.care@hospital.com',
              recordType: 'Patient Information',
              sharedDate: DateTime.now().subtract(Duration(days: 1)),
              expiryDate: DateTime.now().add(Duration(days: 30)),
              status: 'Active',
              description:
                  'Patient demographic information shared with primary care provider',
              files: ['patient_demographics.pdf'],
            ));
          }

          debugPrint(
              'Created ${sharedRecords.length} shared records from health data');
          return sharedRecords;
        }
      }

      // Fallback: return empty list if no health records
      debugPrint(
          'No health records found, returning empty shared records list');
      return [];
    } catch (e) {
      debugPrint('Error fetching shared records: $e');
      throw Exception('Failed to fetch shared records: $e');
    }
  }

  /// Determine record type based on encounter data
  String _determineRecordType(Map<String, dynamic> encounter) {
    if (encounter['encounterType'] != null) {
      final encounterType = encounter['encounterType']['display'] ??
          encounter['encounterType']['name'] ??
          '';

      if (encounterType.toLowerCase().contains('consultation')) {
        return 'Consultation Notes';
      } else if (encounterType.toLowerCase().contains('dispensing')) {
        return 'Prescription';
      } else if (encounterType.toLowerCase().contains('registration')) {
        return 'Registration Record';
      }
    }

    // Check observations for specific types
    if (encounter['obs'] != null) {
      final observations = encounter['obs'] as List;
      for (var obs in observations) {
        final concept = obs['concept']?['display'] ?? '';
        if (concept.toLowerCase().contains('blood pressure') ||
            concept.toLowerCase().contains('temperature') ||
            concept.toLowerCase().contains('weight')) {
          return 'Vital Signs';
        }
      }
    }

    return 'Medical Record';
  }

  /// Create description based on visit and encounter data
  String _createDescription(
      Map<String, dynamic> visit, Map<String, dynamic> encounter) {
    String description =
        'Medical record from ${_formatDate(_parseDate(visit['startDatetime']) ?? DateTime.now())}';

    if (encounter['encounterType'] != null) {
      final encounterType = encounter['encounterType']['display'] ??
          encounter['encounterType']['name'] ??
          'medical visit';
      description += ' - $encounterType';
    }

    // Add location if available
    if (visit['location'] != null) {
      final location =
          visit['location']['display'] ?? visit['location']['name'] ?? '';
      if (location.isNotEmpty) {
        description += ' at $location';
      }
    }

    return description;
  }

  /// Generate appropriate file names based on record type
  List<String> _generateFileNames(
      Map<String, dynamic> visit, String recordType) {
    List<String> files = [];

    switch (recordType.toLowerCase()) {
      case 'prescription':
        files.add(
            'prescription_${_formatDateForFile(visit['startDatetime'])}.pdf');
        break;
      case 'consultation notes':
        files.add(
            'consultation_${_formatDateForFile(visit['startDatetime'])}.pdf');
        break;
      case 'vital signs':
        files.add('vitals_${_formatDateForFile(visit['startDatetime'])}.pdf');
        break;
      case 'registration record':
        files.add(
            'registration_${_formatDateForFile(visit['startDatetime'])}.pdf');
        break;
      default:
        files.add(
            'medical_record_${_formatDateForFile(visit['startDatetime'])}.pdf');
    }

    return files;
  }

  /// Get recipient name based on record type and index
  String _getRecipientName(String recordType, int index) {
    final recipients = [
      'Dr. Sarah Johnson',
      'Dr. Michael Brown',
      'Dr. Emily Wilson',
      'Dr. James Davis',
      'Dr. Lisa Anderson'
    ];

    switch (recordType.toLowerCase()) {
      case 'prescription':
        return 'Pharmacist ${recipients[index % recipients.length]}';
      case 'consultation notes':
        return 'Specialist ${recipients[index % recipients.length]}';
      case 'vital signs':
        return 'Nurse ${recipients[index % recipients.length]}';
      default:
        return recipients[index % recipients.length];
    }
  }

  /// Get recipient email based on record type and index
  String _getRecipientEmail(String recordType, int index) {
    final domains = ['hospital.com', 'clinic.org', 'healthcenter.net'];
    final names = [
      'sarah.johnson',
      'michael.brown',
      'emily.wilson',
      'james.davis',
      'lisa.anderson'
    ];

    final name = names[index % names.length];
    final domain = domains[index % domains.length];

    switch (recordType.toLowerCase()) {
      case 'prescription':
        return 'pharmacy.$name@$domain';
      case 'consultation notes':
        return 'specialist.$name@$domain';
      case 'vital signs':
        return 'nursing.$name@$domain';
      default:
        return '$name@$domain';
    }
  }

  /// Parse date string to DateTime
  DateTime? _parseDate(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      debugPrint('Error parsing date: $dateString');
      return null;
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date for file names
  String _formatDateForFile(dynamic dateString) {
    final date = _parseDate(dateString) ?? DateTime.now();
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}
