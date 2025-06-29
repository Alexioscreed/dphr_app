import 'package:flutter/material.dart';

class VisitDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> visitData;

  const VisitDetailsWidget({
    Key? key,
    required this.visitData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVisitTimeline(context),
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

  Widget _buildVisitTimeline(BuildContext context) {
    final theme = Theme.of(context);
    final startTime = visitData['startTime'] ?? '12:37:47';
    final stopTime = visitData['stopTime'] ?? '12:37:53';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Started new visit at $startTime',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.stop,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Visit was stopped at $stopTime',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationsSection(BuildContext context) {
    final theme = Theme.of(context);
    final medications = visitData['medications'] ?? _getSampleMedications();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.medication,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Medications Prescribed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...medications.map<Widget>(
            (medication) => _buildMedicationCard(context, medication)),
      ],
    );
  }

  Widget _buildMedicationCard(
      BuildContext context, Map<String, dynamic> medication) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medication name and prescription details
          Text(
            '${medication['name']} prescribed on ${medication['prescribedDate']} by ${medication['prescriber']}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),

          // Dosage instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${medication['dosage']} ${medication['frequency']} ${medication['duration']} ${medication['route']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosesSection(BuildContext context) {
    final theme = Theme.of(context);
    final diagnoses = visitData['diagnoses'] ?? _getSampleDiagnoses();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.medical_services,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Confirmed Diagnoses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...diagnoses.map<Widget>(
            (diagnosis) => _buildDiagnosisCard(context, diagnosis)),
      ],
    );
  }

  Widget _buildDiagnosisCard(BuildContext context, String diagnosis) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              diagnosis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleMedications() {
    return [
      {
        'name': 'Cetirizine Tablet 10mg',
        'prescribedDate': '18-02-2025 12:49:57',
        'prescriber': 'Rosemary Gabriel Wakolela',
        'dosage': '1 (tablet)',
        'frequency': 'od',
        'duration': '5 Days',
        'route': 'Oral',
      },
      {
        'name': 'Paracetamol 500mg Tablet(s)',
        'prescribedDate': '18-02-2025 12:49:41',
        'prescriber': 'Rosemary Gabriel Wakolela',
        'dosage': '2 (tablet)',
        'frequency': 'tds / 8 hrly',
        'duration': '3 Days',
        'route': 'Oral',
      },
    ];
  }

  List<String> _getSampleDiagnoses() {
    return [
      '(J00) Acute Nasopharyngitis [Common Cold]',
    ];
  }
}
