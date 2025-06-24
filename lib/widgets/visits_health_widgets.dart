import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_health_records.dart';

class DemographicsCard extends StatelessWidget {
  final PatientDemographics patient;

  const DemographicsCard({
    Key? key,
    required this.patient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Patient Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Name', '${patient.firstName ?? ''} ${patient.lastName ?? ''}'),
            _buildInfoRow('Gender', patient.gender ?? 'N/A'),
            _buildInfoRow('Date of Birth', _formatDate(patient.birthdate)),
            _buildInfoRow(
                'Age',
                (patient.age?.toString()) ??
                    _calculateAge(patient.birthdate).toString()),
            if (patient.phoneNumber?.isNotEmpty == true)
              _buildInfoRow('Phone', patient.phoneNumber!),
            if (patient.address?.isNotEmpty == true)
              _buildInfoRow('Address', patient.address!),
            if (patient.mrn?.isNotEmpty == true)
              _buildInfoRow('MRN', patient.mrn!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not available';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  int _calculateAge(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(dateString);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}

class HealthSummaryView extends StatelessWidget {
  final PatientHealthRecords healthRecords;

  const HealthSummaryView({
    Key? key,
    required this.healthRecords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(
            'Total Visits',
            (healthRecords.visits?.length ?? 0).toString(),
            Icons.local_hospital,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Total Encounters',
            _getTotalEncounters().toString(),
            Icons.medical_services,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Total Prescriptions',
            _getTotalPrescriptions().toString(),
            Icons.medication,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Total Diagnoses',
            _getTotalDiagnoses().toString(),
            Icons.assignment,
            Colors.red,
          ),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildVisitTypesChart(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRecentActivity() {
    final recentVisits = healthRecords.visits?.take(3).toList() ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentVisits.isEmpty)
              const Text('No recent visits found')
            else
              Column(
                children: recentVisits
                    .map((visit) => _buildRecentVisitItem(visit))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentVisitItem(VisitRecord visit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.visitType ?? 'Visit',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (visit.startDate != null)
                  Text(
                    _formatDate(visit.startDate!),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitTypesChart() {
    final visitTypes = <String, int>{};
    for (final visit in healthRecords.visits ?? []) {
      final type = visit.visitType ?? 'Unknown';
      visitTypes[type] = (visitTypes[type] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visit Types Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: visitTypes.entries.map((entry) {
                final percentage =
                    (entry.value / (healthRecords.visits?.length ?? 1) * 100)
                        .round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(entry.key),
                      ),
                      Expanded(
                        flex: 5,
                        child: LinearProgressIndicator(
                          value:
                              entry.value / (healthRecords.visits?.length ?? 1),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$percentage%'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalEncounters() {
    return healthRecords.visits
            ?.expand((visit) => visit.encounters ?? [])
            .length ??
        0;
  }

  int _getTotalPrescriptions() {
    return healthRecords.visits
            ?.expand((visit) => visit.encounters ?? [])
            .expand((encounter) => encounter.prescriptions ?? [])
            .length ??
        0;
  }

  int _getTotalDiagnoses() {
    return healthRecords.visits
            ?.expand((visit) => visit.encounters ?? [])
            .expand((encounter) => encounter.diagnoses ?? [])
            .length ??
        0;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class HealthTimelineView extends StatelessWidget {
  final PatientHealthRecords healthRecords;

  const HealthTimelineView({
    Key? key,
    required this.healthRecords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedVisits = List<VisitRecord>.from(healthRecords.visits ?? []);
    sortedVisits.sort((a, b) {
      final dateA = DateTime.tryParse(a.startDate ?? '') ?? DateTime(1900);
      final dateB = DateTime.tryParse(b.startDate ?? '') ?? DateTime(1900);
      return dateB.compareTo(dateA); // Most recent first
    });

    if (sortedVisits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No visits found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedVisits.length,
      itemBuilder: (context, index) {
        final visit = sortedVisits[index];
        return _buildTimelineItem(visit, index == sortedVisits.length - 1);
      },
    );
  }

  Widget _buildTimelineItem(VisitRecord visit, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getVisitTypeColor(visit.visitType),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        visit.visitType ?? 'Visit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (visit.startDate != null)
                        Text(
                          _formatDate(visit.startDate!),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (visit.location?.isNotEmpty == true)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          visit.location!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  if (visit.encounters?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Encounters:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: visit.encounters!
                          .map((encounter) => _buildEncounterItem(encounter))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEncounterItem(EncounterRecord encounter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  encounter.encounterType ?? 'Encounter',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (encounter.diagnoses?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            const Text('Diagnoses:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            ...encounter.diagnoses!.map((diagnosis) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• $diagnosis'),
                )),
          ],
          if (encounter.prescriptions?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            const Text('Prescriptions:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            ...encounter.prescriptions!.map((prescription) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                      '• ${prescription.conceptDisplay ?? prescription.concept ?? 'Unknown medication'}'),
                )),
          ],
          if (encounter.observations?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            const Text('Observations:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            ...encounter.observations!.map((observation) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                      '• ${observation.conceptDisplay ?? observation.concept ?? 'Unknown'}: ${observation.value ?? observation.valueDisplay ?? 'N/A'}'),
                )),
          ],
        ],
      ),
    );
  }

  Color _getVisitTypeColor(String? visitType) {
    switch (visitType?.toLowerCase()) {
      case 'outpatient':
        return Colors.blue;
      case 'inpatient':
        return Colors.red;
      case 'emergency':
        return Colors.orange;
      case 'specialist':
        return Colors.purple;
      case 'laboratory':
        return Colors.green;
      case 'consultation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class VisitsListView extends StatelessWidget {
  final List<VisitRecord> visits;
  final String selectedFilter;

  const VisitsListView({
    Key? key,
    required this.visits,
    required this.selectedFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredVisits = _filterVisits();

    if (filteredVisits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No visits found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (selectedFilter != 'All')
              Text(
                'Try changing the filter',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredVisits.length,
      itemBuilder: (context, index) {
        final visit = filteredVisits[index];
        return _buildVisitCard(context, visit);
      },
    );
  }

  List<VisitRecord> _filterVisits() {
    if (selectedFilter == 'All') {
      return visits;
    }

    return visits.where((visit) {
      final visitType = visit.visitType?.toLowerCase() ?? '';
      final filter = selectedFilter.toLowerCase();
      return visitType.contains(filter);
    }).toList();
  }

  Widget _buildVisitCard(BuildContext context, VisitRecord visit) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getVisitTypeColor(visit.visitType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getVisitTypeIcon(visit.visitType),
            color: _getVisitTypeColor(visit.visitType),
          ),
        ),
        title: Text(
          visit.visitType ?? 'Visit',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visit.startDate != null)
              Text(
                _formatDate(visit.startDate!),
                style: const TextStyle(color: Colors.grey),
              ),
            if (visit.location?.isNotEmpty == true)
              Text(
                visit.location!,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (visit.encounters?.isNotEmpty == true) ...[
                  const Text(
                    'Encounters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: visit.encounters!
                        .map((encounter) => _buildEncounterDetails(encounter))
                        .toList(),
                  ),
                ] else
                  const Text(
                    'No encounter details available',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterDetails(EncounterRecord encounter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            encounter.encounterType ?? 'Encounter',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (encounter.diagnoses?.isNotEmpty == true) ...[
            _buildSectionHeader('Diagnoses', Icons.assignment),
            ...encounter.diagnoses!.map((diagnosis) => _buildListItem(
                  diagnosis,
                  null,
                )),
            const SizedBox(height: 8),
          ],
          if (encounter.prescriptions?.isNotEmpty == true) ...[
            _buildSectionHeader('Prescriptions', Icons.medication),
            ...encounter.prescriptions!.map((prescription) => _buildListItem(
                  prescription.conceptDisplay ??
                      prescription.concept ??
                      'Unknown medication',
                  prescription.dosage,
                )),
            const SizedBox(height: 8),
          ],
          if (encounter.observations?.isNotEmpty == true) ...[
            _buildSectionHeader('Observations', Icons.monitor_heart),
            ...encounter.observations!.map((observation) => _buildListItem(
                  '${observation.conceptDisplay ?? observation.concept ?? 'Unknown'}: ${observation.value ?? observation.valueDisplay ?? 'N/A'}',
                  observation.units,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String primary, String? secondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $primary',
            style: const TextStyle(fontSize: 13),
          ),
          if (secondary?.isNotEmpty == true)
            Text(
              '  $secondary',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Color _getVisitTypeColor(String? visitType) {
    switch (visitType?.toLowerCase()) {
      case 'outpatient':
        return Colors.blue;
      case 'inpatient':
        return Colors.red;
      case 'emergency':
        return Colors.orange;
      case 'specialist':
        return Colors.purple;
      case 'laboratory':
        return Colors.green;
      case 'consultation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getVisitTypeIcon(String? visitType) {
    switch (visitType?.toLowerCase()) {
      case 'outpatient':
        return Icons.local_hospital;
      case 'inpatient':
        return Icons.hotel;
      case 'emergency':
        return Icons.emergency;
      case 'specialist':
        return Icons.medical_services;
      case 'laboratory':
        return Icons.science;
      case 'consultation':
        return Icons.chat;
      default:
        return Icons.healing;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
