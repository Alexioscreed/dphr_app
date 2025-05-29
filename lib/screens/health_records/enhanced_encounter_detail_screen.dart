import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/encounter.dart';
import '../../models/patient.dart';

class EnhancedEncounterDetailScreen extends StatelessWidget {
  final dynamic encounterId; // Can be int or String

  const EnhancedEncounterDetailScreen({
    Key? key,
    required this.encounterId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final healthRecordProvider = Provider.of<HealthRecordProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final encounter = healthRecordProvider.getEncounterById(encounterId);

    if (encounter == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medical Record Details'),
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
        ),
        body: const Center(
          child: Text('Medical record not found'),
        ),
      );
    }

    // Create patient object from auth user data
    final currentUser = authProvider.currentUser;
    Patient? patient;
    if (currentUser != null) {
      patient = Patient(
        id: int.tryParse(currentUser.id),
        patientUuid: currentUser.patientUuid,
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
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getEncounterTitle(encounter.encounterType)),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share record functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Print record functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEncounterHeader(encounter),
            const SizedBox(height: 24),
            if (patient != null) ...[
              _buildPatientDemographics(patient, encounter),
              const SizedBox(height: 24),
            ],
            _buildEncounterSpecificDetails(encounter),
            const SizedBox(height: 24),
            if (encounter.vitalSigns.isNotEmpty) ...[
              _buildVitalSignsCard(encounter),
              const SizedBox(height: 24),
            ],
            if (encounter.labResults.isNotEmpty) ...[
              _buildLabResultsCard(encounter),
              const SizedBox(height: 24),
            ],
            if (encounter.diagnoses.isNotEmpty) ...[
              _buildDiagnosesCard(encounter),
              const SizedBox(height: 24),
            ],
            if (encounter.medications.isNotEmpty) ...[
              _buildMedicationsCard(encounter),
              const SizedBox(height: 24),
            ],
            if (encounter.treatments.isNotEmpty) ...[
              _buildTreatmentsCard(encounter),
              const SizedBox(height: 24),
            ],
            _buildEncounterNotes(encounter),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterHeader(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getEncounterTitle(encounter.encounterType),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(encounter.encounterDateTime),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  encounter.location,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  encounter.provider,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(encounter.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                encounter.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDemographics(Patient patient, Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDemographicRow(
                'Name', '${patient.firstName} ${patient.lastName}'),
            _buildDemographicRow('MRN', patient.mrn ?? 'N/A'),
            if (patient.dateOfBirth != null)
              _buildDemographicRow(
                  'Age', _calculateAge(patient.dateOfBirth!).toString()),
            if (patient.dateOfBirth != null)
              _buildDemographicRow(
                  'Date of Birth', _formatDate(patient.dateOfBirth!)),
            _buildDemographicRow('Gender', patient.gender ?? 'N/A'),
            _buildDemographicRow('Blood Type', patient.bloodType ?? 'N/A'),
            _buildDemographicRow(
                'Arrival Time', _formatTime(encounter.encounterDateTime)),
            if (patient.allergies != null && patient.allergies!.isNotEmpty)
              _buildDemographicRow('Allergies', patient.allergies!),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterSpecificDetails(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Encounter Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildEncounterTypeSpecificInfo(encounter),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterTypeSpecificInfo(Encounter encounter) {
    switch (encounter.encounterType.toLowerCase()) {
      case 'patient_registration':
        return _buildRegistrationInfo(encounter);
      case 'consultation':
        return _buildConsultationInfo(encounter);
      case 'dispensing':
        return _buildDispensingInfo(encounter);
      case 'laboratory':
      case 'lab_test':
        return _buildLaboratoryInfo(encounter);
      default:
        return _buildGeneralInfo(encounter);
    }
  }

  Widget _buildRegistrationInfo(Encounter encounter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Registration Type', 'New Patient'),
        _buildInfoRow('Status', encounter.status),
        if (encounter.chiefComplaint != null)
          _buildInfoRow('Chief Complaint', encounter.chiefComplaint!),
        if (encounter.diagnosis.isNotEmpty)
          _buildInfoRow('Initial Assessment', encounter.diagnosis),
      ],
    );
  }

  Widget _buildConsultationInfo(Encounter encounter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (encounter.doctor != null) ...[
          _buildInfoRow('Doctor', encounter.doctor!.fullName),
          if (encounter.doctor!.specialization != null)
            _buildInfoRow('Specialization', encounter.doctor!.specialization!),
        ],
        if (encounter.chiefComplaint != null)
          _buildInfoRow('Chief Complaint', encounter.chiefComplaint!),
        if (encounter.diagnosis.isNotEmpty)
          _buildInfoRow('Diagnosis', encounter.diagnosis),
        _buildInfoRow('Consultation Type', 'Medical Consultation'),
      ],
    );
  }

  Widget _buildDispensingInfo(Encounter encounter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Service Type', 'Medication Dispensing'),
        _buildInfoRow('Pharmacist', encounter.provider),
        if (encounter.medications.isNotEmpty)
          _buildInfoRow(
              'Medications Count', '${encounter.medications.length} item(s)'),
        _buildInfoRow('Status', encounter.status),
      ],
    );
  }

  Widget _buildLaboratoryInfo(Encounter encounter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Service Type', 'Laboratory Testing'),
        _buildInfoRow('Technician', encounter.provider),
        if (encounter.labResults.isNotEmpty)
          _buildInfoRow(
              'Tests Performed', '${encounter.labResults.length} test(s)'),
        _buildInfoRow('Collection Status', encounter.status),
      ],
    );
  }

  Widget _buildGeneralInfo(Encounter encounter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
            'Encounter Type', _getEncounterTitle(encounter.encounterType)),
        _buildInfoRow('Provider', encounter.provider),
        if (encounter.diagnosis.isNotEmpty)
          _buildInfoRow('Primary Diagnosis', encounter.diagnosis),
        _buildInfoRow('Status', encounter.status),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsCard(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vital Signs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...encounter.vitalSigns
                .map((vital) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatVitalSignType(vital.type),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${vital.value} ${_getVitalSignUnit(vital.type)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabResultsCard(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lab Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...encounter.labResults
                .map((lab) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lab.testName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getLabStatusColor(lab.status),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  lab.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Result: ${lab.value} ${lab.unit}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Normal: ${lab.normalRange}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosesCard(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diagnoses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...encounter.diagnoses
                .map((diagnosis) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagnosis.diagnosisName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (diagnosis.diagnosisCode.isNotEmpty)
                            Text(
                              'Code: ${diagnosis.diagnosisCode}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          if (diagnosis.description.isNotEmpty)
                            Text(
                              diagnosis.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsCard(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...encounter.medications
                .map((medication) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.medicationName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dosage: ${medication.dosage}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Frequency: ${medication.frequency}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (medication.instructions.isNotEmpty)
                            Text(
                              'Instructions: ${medication.instructions}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentsCard(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Treatments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...encounter.treatments
                .map((treatment) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            treatment.treatmentName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (treatment.description.isNotEmpty)
                            Text(
                              treatment.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                          if (treatment.provider.isNotEmpty)
                            Text(
                              'Provider: ${treatment.provider}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterNotes(Encounter encounter) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              encounter.notes.isNotEmpty
                  ? encounter.notes
                  : 'No clinical notes available.',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _getEncounterTitle(String type) {
    switch (type.toLowerCase()) {
      case 'patient_registration':
        return 'Patient Registration';
      case 'consultation':
        return 'Medical Consultation';
      case 'dispensing':
        return 'Medication Dispensing';
      case 'laboratory':
      case 'lab_test':
        return 'Laboratory Tests';
      case 'emergency':
        return 'Emergency Visit';
      case 'preventive':
        return 'Preventive Care';
      case 'specialist':
        return 'Specialist Consultation';
      case 'follow_up':
        return 'Follow-up Visit';
      case 'urgent_care':
        return 'Urgent Care';
      default:
        return type
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '')
            .join(' ');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, y \'at\' h:mm a').format(dateTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getLabStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'abnormal':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatVitalSignType(String type) {
    switch (type.toLowerCase()) {
      case 'blood_pressure':
        return 'Blood Pressure';
      case 'heart_rate':
        return 'Heart Rate';
      case 'temperature':
        return 'Temperature';
      case 'respiratory_rate':
        return 'Respiratory Rate';
      case 'oxygen_saturation':
        return 'Oxygen Saturation';
      case 'weight':
        return 'Weight';
      case 'height':
        return 'Height';
      default:
        return type
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '')
            .join(' ');
    }
  }

  String _getVitalSignUnit(String type) {
    switch (type.toLowerCase()) {
      case 'blood_pressure':
        return 'mmHg';
      case 'heart_rate':
        return 'bpm';
      case 'temperature':
        return '°F';
      case 'respiratory_rate':
        return '/min';
      case 'oxygen_saturation':
        return '%';
      case 'weight':
        return 'lbs';
      case 'height':
        return 'in';
      default:
        return '';
    }
  }
}
