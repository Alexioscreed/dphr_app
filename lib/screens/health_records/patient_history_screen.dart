import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/patient_health_records.dart';
import '../../services/pdf_service.dart';
import '../../providers/visits_health_provider.dart';

class PatientHistoryScreen extends StatefulWidget {
  final VisitRecord visit;

  const PatientHistoryScreen({
    Key? key,
    required this.visit,
  }) : super(key: key);

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  bool _isPrinting = false;

  Future<void> _printVisitSummary() async {
    try {
      setState(() {
        _isPrinting = true;
      });

      // Get the visits provider to access patient demographics
      final visitsProvider =
          Provider.of<VisitsHealthProvider>(context, listen: false);

      // Get the current patient demographics
      final demographics = visitsProvider.healthRecords?.demographics;

      if (demographics == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient information not available')),
        );
        return;
      }

      // Generate PDF
      final pdfService = PdfService();
      final pdfPath = await pdfService.generateVisitPdf(
        visit: widget.visit,
        demographics: demographics,
        appName: 'DPHR - Digital Personal Health Records',
      );

      // Open the PDF
      await pdfService.openPdf(pdfPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to: $pdfPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.visit.visitType ?? 'Patient History'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          _isPrinting
              ? Container(
                  margin: const EdgeInsets.all(16),
                  width: 24,
                  height: 24,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Print visit summary',
                  onPressed: _printVisitSummary,
                ),
        ],
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
                    color: _getVisitTypeColor(widget.visit.visitType)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getVisitTypeIcon(widget.visit.visitType),
                    color: _getVisitTypeColor(widget.visit.visitType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.visit.visitType ?? 'Visit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (widget.visit.location?.isNotEmpty == true)
                        Text(
                          '📍 ${widget.visit.location!}',
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
                if (widget.visit.startDatetime != null ||
                    widget.visit.startDate != null)
                  Expanded(
                    child: _buildDateInfo(
                      'Started',
                      widget.visit.startDatetime ?? widget.visit.startDate!,
                      Icons.play_arrow,
                      Colors.green,
                    ),
                  ),
                if (widget.visit.stopDatetime != null ||
                    widget.visit.endDate != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateInfo(
                      'Ended',
                      widget.visit.stopDatetime ?? widget.visit.endDate!,
                      Icons.stop,
                      Colors.red,
                    ),
                  ),
                ],
              ],
            ),
            if (widget.visit.status?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.visit.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Status: ${widget.visit.status!}',
                  style: TextStyle(
                    color: _getStatusColor(widget.visit.status),
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
        color: color.withOpacity(0.1),
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

    if (widget.visit.encounters != null) {
      for (final encounter in widget.visit.encounters!) {
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
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
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
    if (widget.visit.encounters != null) {
      for (final encounter in widget.visit.encounters!) {
        if (encounter.prescriptions != null) {
          for (final prescription in encounter.prescriptions!) {
            // Build medication name with drug strength if available
            String medicationName = prescription.conceptDisplay ??
                prescription.concept ??
                'Unknown Medication';

            // Add drug strength to the medication name if available
            if (prescription.drugStrength != null &&
                prescription.drugStrength!.isNotEmpty) {
              if (!medicationName
                  .toLowerCase()
                  .contains(prescription.drugStrength!.toLowerCase())) {
                medicationName = '$medicationName ${prescription.drugStrength}';
              }
            }

            medications.add({
              'name': medicationName,
              'dosage': prescription.dosage,
              'frequency': prescription.frequency,
              'duration': prescription.duration,
              'instructions': prescription.instructions,
              'drugStrength':
                  prescription.drugStrength, // Include drug strength separately
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
    if (widget.visit.encounters != null) {
      for (final encounter in widget.visit.encounters!) {
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
                color: Colors.red.withOpacity(0.1),
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
