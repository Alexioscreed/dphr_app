import '../models/api_models.dart';
import '../models/health_record.dart';
import '../models/vital_measurement.dart';
import '../models/symptom.dart';
import 'constants.dart';

class DataTransformer {
  // Transform app models to API models

  // Transform client data for registration
  static ClientRegistration transformClientForRegistration({
    required String mrn,
    required String firstName,
    String? middleName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    List<String>? phoneNumbers,
    List<String>? emails,
    String? occupation,
    String? maritalStatus,
    String? nationality,
    List<Address>? addresses,
    List<ContactPerson>? contactPeople,
    List<PaymentDetail>? paymentDetails,
  }) {
    final identifiers = [
      Identifier(
        type: 'MRN',
        id: mrn,
        preferred: true,
      ),
    ];

    return ClientRegistration(
      facilityDetails: FacilityDetails(
        code: ApiConstants.hfrCode,
        name: ApiConstants.facilityName,
      ),
      demographicDetails: DemographicDetails(
        mrn: mrn,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        dateOfBirth: dateOfBirth.toIso8601String().split('T')[0],
        gender: gender.toLowerCase(),
        phoneNumbers: phoneNumbers,
        emails: emails,
        occupation: occupation,
        maritalStatus: maritalStatus,
        nationality: nationality,
        addresses: addresses,
        identifiers: identifiers,
        contactPeople: contactPeople,
        paymentDetails: paymentDetails,
      ),
    );
  }

  // Transform health record for submission
  static HealthRecordSubmission transformHealthRecordForSubmission({
    required HealthRecord record,
    required List<Symptom> symptoms,
    required List<VitalMeasurement> vitals,
  }) {
    final templateDetails = TemplateDetails(
      code: 'GENERAL',
      id: 'general',
      name: 'General',
      workflow: WorkflowDetails(
        uuid: '23750fc5-0867-4426-817a-89f155532fa1',
      ),
    );

    final reportDetails = ReportDetails(
      reportingDate: DateTime.now().toIso8601String().split('T')[0],
    );

    final facilityDetails = FacilityDetails(
      code: ApiConstants.hfrCode,
      name: ApiConstants.facilityName,
    );

    final listGridItem = ListGridItem(
      demographicDetails: DemographicDetails(
        mrn: record.id,
        firstName: '', // These would be populated from actual patient data
        lastName: '',
        dateOfBirth: DateTime.now().toIso8601String().split('T')[0],
        gender: 'unknown',
        identifiers: [
          Identifier(
            type: 'MRN',
            id: record.id,
            preferred: true,
          ),
        ],
      ),
      visitDetails: VisitDetails(
        id: record.id,
        visitDate: record.date.toIso8601String().split('T')[0],
        newThisYear: false,
        isNew: false,
        visitType: 'General',
      ),
      diagnosisDetails: _transformDiagnosis(record),
      clinicalInformation: _transformClinicalInfo(symptoms, vitals),
      outcomeDetails: OutcomeDetails(
        isAlive: true,
        referred: false,
      ),
    );

    return HealthRecordSubmission(
      templateDetails: templateDetails,
      data: SubmissionData(
        facilityDetails: facilityDetails,
        reportDetails: reportDetails,
        listGrid: [listGridItem],
      ),
    );
  }

  // Helper method to transform diagnosis
  static List<DiagnosisDetail>? _transformDiagnosis(HealthRecord record) {
    if (record.type.isEmpty) return null;

    return [
      DiagnosisDetail(
        certainty: 'CONFIRMED',
        diagnosis: '${record.type} ${record.description}',
        diagnosisCode: record.type,
        diagnosisDate: record.date.toIso8601String().split('T')[0],
        diagnosisDescription: record.description,
      ),
    ];
  }

  // Helper method to transform clinical information
  static ClinicalInformation _transformClinicalInfo(List<Symptom> symptoms, List<VitalMeasurement> vitals) {
    final vitalSigns = _transformVitals(vitals);
    final visitNotes = _transformSymptoms(symptoms);

    return ClinicalInformation(
      vitalSigns: vitalSigns,
      visitNotes: visitNotes,
    );
  }

  // Helper method to transform vital signs
  static List<VitalSign>? _transformVitals(List<VitalMeasurement> vitals) {
    if (vitals.isEmpty) return null;

    List<VitalSign> vitalSigns = [];

    for (var vital in vitals) {
      VitalSign vitalSign;

      switch (vital.type) {
        case 'Blood Pressure':
          vitalSign = VitalSign(
            bloodPressure: vital.value,
            dateTime: vital.date.toIso8601String(),
          );
          break;
        case 'Weight':
          vitalSign = VitalSign(
            weight: vital.value,
            dateTime: vital.date.toIso8601String(),
          );
          break;
        case 'Temperature':
          vitalSign = VitalSign(
            temperature: vital.value,
            dateTime: vital.date.toIso8601String(),
          );
          break;
        case 'Heart Rate':
          vitalSign = VitalSign(
            pulseRate: vital.value,
            dateTime: vital.date.toIso8601String(),
          );
          break;
        default:
          vitalSign = VitalSign(
            dateTime: vital.date.toIso8601String(),
          );
      }

      vitalSigns.add(vitalSign);
    }

    return vitalSigns;
  }

  // Helper method to transform symptoms to visit notes
  static List<VisitNote>? _transformSymptoms(List<Symptom> symptoms) {
    if (symptoms.isEmpty) return null;

    List<VisitNote> visitNotes = [];

    for (var symptom in symptoms) {
      visitNotes.add(
        VisitNote(
          note: 'Symptom: ${symptom.name}, Severity: ${symptom.severity}, Notes: ${symptom.notes}',
          dateTime: symptom.date.toIso8601String(),
        ),
      );
    }

    return visitNotes;
  }

  // Transform for referral submission
  static ReferralSubmission transformReferralSubmission({
    required String patientId,
    required String patientFirstName,
    required String patientLastName,
    required DateTime patientDateOfBirth,
    required String patientGender,
    required String toFacilityCode,
    required String toFacilityName,
    required String referralReason,
    List<DiagnosisDetail>? diagnosisDetails,
    List<MedicationDetail>? medicationDetails,
    List<InvestigationDetail>? investigationDetails,
    String? notes,
  }) {
    return ReferralSubmission(
      fromFacility: FacilityDetails(
        code: ApiConstants.hfrCode,
        name: ApiConstants.facilityName,
      ),
      toFacility: FacilityDetails(
        code: toFacilityCode,
        name: toFacilityName,
      ),
      patientDetails: DemographicDetails(
        mrn: patientId,
        firstName: patientFirstName,
        lastName: patientLastName,
        dateOfBirth: patientDateOfBirth.toIso8601String().split('T')[0],
        gender: patientGender.toLowerCase(),
        identifiers: [
          Identifier(
            type: 'MRN',
            id: patientId,
            preferred: true,
          ),
        ],
      ),
      referralDate: DateTime.now().toIso8601String().split('T')[0],
      referralReason: referralReason,
      diagnosisDetails: diagnosisDetails,
      medicationDetails: medicationDetails,
      investigationDetails: investigationDetails,
      notes: notes,
    );
  }

  // Transform API models to app models

  // Transform API health record to app health record
  static HealthRecord transformApiHealthRecordToAppHealthRecord(HealthRecordData apiRecord) {
    String title = 'Visit: ${apiRecord.visitDetails.visitType}';
    String type = 'Medical';
    String description = '';
    List<String> attachments = [];

    // Extract diagnosis if available
    if (apiRecord.diagnosisDetails != null && apiRecord.diagnosisDetails!.isNotEmpty) {
      final diagnosis = apiRecord.diagnosisDetails![0];
      title = diagnosis.diagnosis;
      type = diagnosis.diagnosisCode;
      description = diagnosis.diagnosisDescription;
    }

    // Extract attachments if available
    if (apiRecord.clinicalInformation?.visitNotes != null) {
      attachments.add('Visit Notes');
    }
    if (apiRecord.clinicalInformation?.vitalSigns != null) {
      attachments.add('Vital Signs');
    }
    if (apiRecord.medicationDetails != null && apiRecord.medicationDetails!.isNotEmpty) {
      attachments.add('Medications');
    }
    if (apiRecord.labInvestigationDetails != null && apiRecord.labInvestigationDetails!.isNotEmpty) {
      attachments.add('Lab Results');
    }

    return HealthRecord(
      id: apiRecord.visitDetails.id,
      title: title,
      date: DateTime.parse(apiRecord.visitDetails.visitDate),
      provider: apiRecord.facilityDetails.name,
      type: type,
      description: description,
      attachments: attachments,
    );
  }

  // Transform API vital signs to app vital measurements
  static List<VitalMeasurement> transformApiVitalSignsToAppVitalMeasurements(List<VitalSign> vitalSigns) {
    List<VitalMeasurement> vitalMeasurements = [];

    for (var vitalSign in vitalSigns) {
      if (vitalSign.bloodPressure != null) {
        vitalMeasurements.add(
          VitalMeasurement(
            type: 'Blood Pressure',
            value: vitalSign.bloodPressure!,
            date: DateTime.parse(vitalSign.dateTime),
            notes: '',
          ),
        );
      }

      if (vitalSign.weight != null) {
        vitalMeasurements.add(
          VitalMeasurement(
            type: 'Weight',
            value: vitalSign.weight!,
            date: DateTime.parse(vitalSign.dateTime),
            notes: '',
          ),
        );
      }

      if (vitalSign.temperature != null) {
        vitalMeasurements.add(
          VitalMeasurement(
            type: 'Temperature',
            value: vitalSign.temperature!,
            date: DateTime.parse(vitalSign.dateTime),
            notes: '',
          ),
        );
      }

      if (vitalSign.pulseRate != null) {
        vitalMeasurements.add(
          VitalMeasurement(
            type: 'Heart Rate',
            value: vitalSign.pulseRate!,
            date: DateTime.parse(vitalSign.dateTime),
            notes: '',
          ),
        );
      }
    }

    return vitalMeasurements;
  }
}

