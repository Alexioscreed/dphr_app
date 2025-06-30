import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/patient_health_records.dart';

class PatientHistoryScreen extends StatelessWidget {
  final VisitRecord visit;

  const PatientHistoryScreen({
    Key? key,
    required this.visit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(visit.visitType ?? 'Patient History'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVisitSummary(context),
              const SizedBox(height: 24),
              _buildMedicationsSection(context),
              const SizedBox(height: 24),
              _buildDiagnosesSection(context),
              const SizedBox(height: 24),
              _buildObservationsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitSummary(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getVisitTypeColor(visit.visitType)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getVisitTypeIcon(visit.visitType),
                    color: _getVisitTypeColor(visit.visitType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.visitType ?? 'Visit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (visit.location?.isNotEmpty == true)
                        Text(
                          '📍 ${visit.location!}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (visit.startDatetime != null || visit.startDate != null)
                  Expanded(
                    child: _buildDateInfo(
                      'Started',
                      visit.startDatetime ?? visit.startDate!,
                      Icons.play_arrow,
                      Colors.green,
                    ),
                  ),
                if (visit.stopDatetime != null || visit.endDate != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateInfo(
                      'Ended',
                      visit.stopDatetime ?? visit.endDate!,
                      Icons.stop,
                      Colors.red,
                    ),
                  ),
                ],
              ],
            ),
            if (visit.status?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(visit.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Status: ${visit.status!}',
                  style: TextStyle(
                    color: _getStatusColor(visit.status),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(
      String label, String dateTime, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDateTime(dateTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection(BuildContext context) {
    // Collect all formatted prescriptions from encounters
    List<String> formattedPrescriptions = [];

    if (visit.encounters != null) {
      for (final encounter in visit.encounters!) {
        if (encounter.formattedPrescriptions != null &&
            encounter.formattedPrescriptions!.isNotEmpty) {
          formattedPrescriptions.add(encounter.formattedPrescriptions!);
        }
      }
    }

    // If no formatted prescriptions available, fall back to individual medications
    if (formattedPrescriptions.isEmpty) {
      return _buildIndividualMedicationsSection(context);
    }

    return _buildSection(
      'Medications & Prescriptions',
      Icons.medication,
      [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: formattedPrescriptions.map((prescriptionText) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  prescriptionText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualMedicationsSection(BuildContext context) {
    final medications = <Map<String, dynamic>>[];
    // Extract medications from all encounters
    if (visit.encounters != null) {
      for (final encounter in visit.encounters!) {
        if (encounter.prescriptions != null) {
          for (final prescription in encounter.prescriptions!) {
            medications.add({
              'name': prescription.conceptDisplay ??
                  prescription.concept ??
                  'Unknown Medication',
              'dosage': prescription.dosage,
              'frequency': prescription.frequency,
              'duration': prescription.duration,
              'instructions': prescription.instructions,
            });
          }
        }
      }
    }

    return _buildSection(
      'Medications (${medications.length})',
      Icons.medication,
      medications.isEmpty
          ? [
              const Text(
                'No medications recorded for this visit',
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            ]
          : medications
              .map((medication) => _buildMedicationCard(medication))
              .toList(),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medication['name'] ?? 'Unknown Medication',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (medication['dosage']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Dosage: ${medication['dosage']}'),
            ],
            if (medication['frequency']?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text('Frequency: ${medication['frequency']}'),
            ],
            if (medication['instructions']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Instructions:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                medication['instructions']!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            if (medication['duration']?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text('Duration: ${medication['duration']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosesSection(BuildContext context) {
    final diagnoses = <String>[];
    // Extract diagnoses from all encounters
    if (visit.encounters != null) {
      for (final encounter in visit.encounters!) {
        if (encounter.diagnoses != null) {
          diagnoses.addAll(encounter.diagnoses!);
        }
      }
    }

    return _buildSection(
      'Diagnoses (${diagnoses.length})',
      Icons.local_hospital,
      diagnoses.isEmpty
          ? [
              const Text(
                'No diagnoses recorded for this visit',
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            ]
          : diagnoses
              .map((diagnosis) => _buildDiagnosisCard(diagnosis))
              .toList(),
    );
  }

  Widget _buildDiagnosisCard(String diagnosis) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.local_hospital, color: Colors.red, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                diagnosis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsSection(BuildContext context) {
    final observations = <Map<String, dynamic>>[];
    // Extract observations from all encounters
    if (visit.encounters != null) {
      for (final encounter in visit.encounters!) {
        if (encounter.observations != null) {
          for (final observation in encounter.observations!) {
            observations.add({
              'name': observation.conceptDisplay ??
                  observation.concept ??
                  'Unknown Test',
              'value': observation.value ?? observation.valueDisplay,
              'unit': observation.units,
              'category': observation.category,
            });
          }
        }
      }
    }

    return _buildSection(
      'Observations & Tests (${observations.length})',
      Icons.science,
      observations.isEmpty
          ? [
              const Text(
                'No observations or tests recorded for this visit',
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              )
            ]
          : observations
              .map((observation) => _buildObservationCard(observation))
              .toList(),
    );
  }

  Widget _buildObservationCard(Map<String, dynamic> observation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.science, color: Colors.blue, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    observation['name'] ?? 'Unknown Test',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (observation['value']?.toString().isNotEmpty == true)
                    Text(
                      'Value: ${observation['value']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  if (observation['unit']?.isNotEmpty == true)
                    Text(
                      'Unit: ${observation['unit']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  if (observation['category']?.isNotEmpty == true)
                    Text(
                      'Category: ${observation['category']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Color _getVisitTypeColor(String? visitType) {
    switch (visitType?.toLowerCase()) {
      case 'emergency':
        return Colors.red;
      case 'outpatient':
        return Colors.blue;
      case 'inpatient':
        return Colors.purple;
      case 'consultation':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getVisitTypeIcon(String? visitType) {
    switch (visitType?.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'outpatient':
        return Icons.local_hospital;
      case 'inpatient':
        return Icons.hotel;
      case 'consultation':
        return Icons.chat;
      default:
        return Icons.medical_services;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'finished':
        return Colors.green;
      case 'in progress':
      case 'ongoing':
        return Colors.orange;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }
}
