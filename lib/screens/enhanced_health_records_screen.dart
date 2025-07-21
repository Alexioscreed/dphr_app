import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/health_records_service.dart';
import '../models/patient_health_records.dart';
import '../widgets/visits_health_widgets.dart';

class EnhancedHealthRecordsScreen extends StatefulWidget {
  const EnhancedHealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedHealthRecordsScreen> createState() =>
      _EnhancedHealthRecordsScreenState();
}

class _EnhancedHealthRecordsScreenState
    extends State<EnhancedHealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;

  PatientHealthRecords? _healthRecords;
  List<VisitRecord> _visits = [];
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Outpatient',
    'Inpatient',
    'Emergency',
    'Specialist',
    'Laboratory',
    'Consultation'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEnhancedHealthRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEnhancedHealthRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final healthRecordsService =
          Provider.of<HealthRecordsService>(context, listen: false);

      // Try to get comprehensive enhanced health records first
      final healthRecords =
          await healthRecordsService.getMyEnhancedHealthRecords();

      // Also get visits separately to ensure we have the latest data
      final visits = await healthRecordsService.getMyEnhancedVisits();

      setState(() {
        _healthRecords = healthRecords;
        _visits = visits;
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Loaded ${visits.length} visits with enhanced details'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your health records...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading health records',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEnhancedHealthRecords,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_healthRecords?.demographics == null && _visits.isEmpty) {
      return const Center(
        child: Text('No health records available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Demographics
          if (_healthRecords?.demographics != null)
            DemographicsCard(patient: _healthRecords!.demographics!),

          // Health Summary Statistics
          _buildHealthSummaryCard(),

          // Recent Visits Summary
          if (_visits.isNotEmpty) _buildRecentVisitsCard(),
        ],
      ),
    );
  }

  Widget _buildHealthSummaryCard() {
    final totalVisits = _visits.length;
    final totalEncounters =
        _visits.expand((visit) => visit.encounters ?? []).length;
    final totalMedications = _visits
        .expand((visit) => visit.encounters ?? [])
        .expand((encounter) => encounter.prescriptions ?? [])
        .length;
    final totalObservations = _visits
        .expand((visit) => visit.encounters ?? [])
        .expand((encounter) => encounter.observations ?? [])
        .length;

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
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Health Summary',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryStatistic(
                    'Visits',
                    totalVisits.toString(),
                    Icons.local_hospital,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryStatistic(
                    'Encounters',
                    totalEncounters.toString(),
                    Icons.medical_services,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryStatistic(
                    'Medications',
                    totalMedications.toString(),
                    Icons.medication,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryStatistic(
                    'Observations',
                    totalObservations.toString(),
                    Icons.monitor_heart,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStatistic(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentVisitsCard() {
    final recentVisits = _visits.take(3).toList();

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
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recent Visits',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentVisits.map((visit) => _buildRecentVisitItem(visit)),
            if (_visits.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: Text('View all ${_visits.length} visits'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentVisitItem(VisitRecord visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_hospital,
              color: Colors.blue[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.visitType ?? 'Visit',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (visit.startDatetime != null || visit.startDate != null)
                  Text(
                    _formatDate(visit.startDatetime ?? visit.startDate!),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                if (visit.location?.isNotEmpty == true)
                  Text(
                    visit.location!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${visit.encounters?.length ?? 0} encounters',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsTab() {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Visits list
        Expanded(
          child: VisitsListView(
            visits: _visits,
            selectedFilter: _selectedFilter,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsTab() {
    final allMedications = <Map<String, dynamic>>[];

    for (final visit in _visits) {
      final healthRecordsService =
          Provider.of<HealthRecordsService>(context, listen: false);
      allMedications
          .addAll(healthRecordsService.extractMedicationsFromVisit(visit));
    }

    if (allMedications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No medications found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allMedications.length,
      itemBuilder: (context, index) {
        final medication = allMedications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: Colors.green[700]),
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
            const SizedBox(height: 12),
            if (medication['dosage'] != null)
              _buildMedicationDetailRow('Dosage', medication['dosage']),
            if (medication['frequency'] != null)
              _buildMedicationDetailRow('Frequency', medication['frequency']),
            if (medication['duration'] != null)
              _buildMedicationDetailRow('Duration', medication['duration']),
            if (medication['instructions'] != null)
              _buildMedicationDetailRow(
                  'Instructions', medication['instructions']),
            if (medication['dateActivated'] != null)
              _buildMedicationDetailRow(
                  'Date Prescribed', _formatDate(medication['dateActivated'])),
            if (medication['encounterDate'] != null)
              _buildMedicationDetailRow(
                  'Visit Date', _formatDate(medication['encounterDate'])),
            if (medication['provider'] != null)
              _buildMedicationDetailRow('Provider', medication['provider']),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Health Records'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Visits', icon: Icon(Icons.local_hospital)),
            Tab(text: 'Medications', icon: Icon(Icons.medication)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildVisitsTab(),
                    _buildMedicationsTab(),
                  ],
                ),
    );
  }
}
