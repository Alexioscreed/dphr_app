import 'package:flutter/material.dart';
import '../../models/api_models.dart';
import '../../utils/data_transformer.dart';
import '../health_records/health_record_detail_screen.dart';

class SharedRecordDetailScreen extends StatelessWidget {
  final HealthRecordData record;

  const SharedRecordDetailScreen({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Transform API record to app record for reusing the existing detail screen
    final appRecord = DataTransformer.transformApiHealthRecordToAppHealthRecord(record);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Record Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save to local records
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record saved to local records')),
              );
            },
            tooltip: 'Save to My Records',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDiagnosisSection(),
            const SizedBox(height: 24),
            _buildVitalSignsSection(),
            const SizedBox(height: 24),
            _buildMedicationsSection(),
            const SizedBox(height: 24),
            _buildLabResultsSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HealthRecordDetailScreen(record: appRecord),
                    ),
                  );
                },
                child: const Text('View in Standard Format'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit: ${record.visitDetails.visitType}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  record.visitDetails.visitDate,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  record.facilityDetails.name,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.folder, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Visit ID: ${record.visitDetails.id}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    if (record.diagnosisDetails == null || record.diagnosisDetails!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diagnosis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: record.diagnosisDetails!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final diagnosis = record.diagnosisDetails![index];
              return ListTile(
                title: Text(diagnosis.diagnosis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Certainty: ${diagnosis.certainty}'),
                    Text('Date: ${diagnosis.diagnosisDate}'),
                    Text('Description: ${diagnosis.diagnosisDescription}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVitalSignsSection() {
    if (record.clinicalInformation?.vitalSigns == null || record.clinicalInformation!.vitalSigns!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vital Signs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: record.clinicalInformation!.vitalSigns!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final vitalSign = record.clinicalInformation!.vitalSigns![index];
              return ListTile(
                title: Text('Date: ${vitalSign.dateTime.split('T')[0]}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vitalSign.bloodPressure != null)
                      Text('Blood Pressure: ${vitalSign.bloodPressure}'),
                    if (vitalSign.weight != null)
                      Text('Weight: ${vitalSign.weight}'),
                    if (vitalSign.temperature != null)
                      Text('Temperature: ${vitalSign.temperature}'),
                    if (vitalSign.height != null)
                      Text('Height: ${vitalSign.height}'),
                    if (vitalSign.respiration != null)
                      Text('Respiration: ${vitalSign.respiration}'),
                    if (vitalSign.pulseRate != null)
                      Text('Pulse Rate: ${vitalSign.pulseRate}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    if (record.medicationDetails == null || record.medicationDetails!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: record.medicationDetails!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final medication = record.medicationDetails![index];
              return ListTile(
                title: Text(medication.medication),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dosage: ${medication.dosage}'),
                    Text('Frequency: ${medication.frequency}'),
                    Text('Duration: ${medication.duration}'),
                    Text('Start Date: ${medication.startDate}'),
                    if (medication.endDate != null)
                      Text('End Date: ${medication.endDate}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabResultsSection() {
    if (record.labInvestigationDetails == null || record.labInvestigationDetails!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lab Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: record.labInvestigationDetails!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final labResult = record.labInvestigationDetails![index];
              return ListTile(
                title: Text(labResult.test),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Result: ${labResult.result} ${labResult.units}'),
                    Text('Reference Range: ${labResult.referenceRange}'),
                    Text('Date: ${labResult.dateTime.split('T')[0]}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    if (record.clinicalInformation?.visitNotes == null || record.clinicalInformation!.visitNotes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: record.clinicalInformation!.visitNotes!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final note = record.clinicalInformation!.visitNotes![index];
              return ListTile(
                title: Text('Date: ${note.dateTime.split('T')[0]}'),
                subtitle: Text(note.note),
              );
            },
          ),
        ),
      ],
    );
  }
}

