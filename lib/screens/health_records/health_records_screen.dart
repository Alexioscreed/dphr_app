import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/health_record_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connectivity_service.dart';
import '../../models/health_record.dart';
import 'health_record_detail_screen.dart';
import 'enhanced_encounter_detail_screen.dart';
import '../../models/encounter.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Consultation',
    'Emergency',
    'Preventive',
    'Specialist',
    'Laboratory',
    'Urgent Care'
  ];
  String _selectedView = 'grouped'; // 'grouped' or 'list'
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHealthRecordsIfAuthenticated();
    });
  }

  Future<void> _fetchHealthRecordsIfAuthenticated() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      _fetchHealthRecords();
    }
  }

  Future<void> _fetchHealthRecords() async {
    final healthRecordProvider =
        Provider.of<HealthRecordProvider>(context, listen: false);
    await healthRecordProvider.fetchHealthRecords();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        return Consumer<HealthRecordProvider>(
          builder: (context, healthRecordProvider, child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Health Records'),
                backgroundColor:
                    isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                actions: [
                  // Offline indicator
                  if (connectivityService.isOffline)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          const Text('Offline',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  // Refresh button
                  IconButton(
                    onPressed: connectivityService.isOnline
                        ? () => healthRecordProvider.refreshHealthRecords()
                        : null,
                    icon: const Icon(Icons.refresh),
                    tooltip: connectivityService.isOnline
                        ? 'Refresh data'
                        : 'No internet connection',
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedView =
                            _selectedView == 'grouped' ? 'list' : 'grouped';
                      });
                    },
                    icon: Icon(_selectedView == 'grouped'
                        ? Icons.view_list
                        : Icons.view_module),
                    tooltip: _selectedView == 'grouped'
                        ? 'List View'
                        : 'Grouped View',
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Offline banner with last sync info
                  if (connectivityService.isOffline &&
                      healthRecordProvider.lastSyncTime != null)
                    Container(
                      width: double.infinity,
                      color: Colors.orange.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing cached data from ${_formatLastSync(healthRecordProvider.lastSyncTime!)}',
                              style: const TextStyle(
                                  color: Colors.orange, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildFilterChips(),
                  Expanded(
                    child: _selectedView == 'grouped'
                        ? _buildGroupedRecordsList()
                        : _buildHealthRecordsList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16.0 : 8.0,
              right: index == _filters.length - 1 ? 16.0 : 0.0,
            ),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor:
                  const Color(0xFF2196F3).withOpacity(0.2), // Updated to blue
              checkmarkColor: const Color(0xFF2196F3), // Updated to blue
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF2196F3)
                    : Colors.black, // Updated to blue
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupedRecordsList() {
    return Consumer<HealthRecordProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchHealthRecords,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final records = provider.healthRecords;

        if (records.isEmpty) {
          return const Center(
            child: Text('No health records found'),
          );
        }

        // Filter records
        final filteredRecords = _selectedFilter == 'All'
            ? records
            : records
                .where((record) => record.type == _selectedFilter)
                .toList();

        if (filteredRecords.isEmpty) {
          return Center(
            child: Text('No ${_selectedFilter.toLowerCase()} records found'),
          );
        }

        // Group records by date
        final Map<String, List<HealthRecord>> groupedRecords = {};
        for (final record in filteredRecords) {
          final dateKey = _formatDateKey(record.date);
          groupedRecords.putIfAbsent(dateKey, () => []);
          groupedRecords[dateKey]!.add(record);
        }

        // Sort date keys in descending order
        final sortedDateKeys = groupedRecords.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return RefreshIndicator(
          onRefresh: _fetchHealthRecords,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedDateKeys.length,
            itemBuilder: (context, dateIndex) {
              final dateKey = sortedDateKeys[dateIndex];
              final dateRecords = groupedRecords[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dateIndex == 0) const SizedBox(height: 8),
                  // Date header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateHeader(dateKey),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Records for this date
                  ...dateRecords.map((record) => _buildRecordCard(record)),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecordCard(HealthRecord record) {
    final provider = Provider.of<HealthRecordProvider>(context, listen: false);
    final Encounter? encounter = provider.encounters
        .where((e) => e.id.toString() == record.id)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: _getEncounterIcon(record.type),
        title: Text(
          _getEncounterDisplayTitle(record.type, encounter),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${_formatTime(record.date)} • ${record.provider}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text('Location: ${encounter?.location ?? record.provider}'),
            const SizedBox(height: 2),
            if (encounter != null) ...[
              _buildEncounterSummary(encounter),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 16),
                  const SizedBox(width: 4),
                  Text('${record.attachments.length} attachment(s)'),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (encounter != null && encounter.id != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    EnhancedEncounterDetailScreen(encounterId: encounter.id!),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    HealthRecordDetailScreen(recordId: record.id),
              ),
            );
          }
        },
      ),
    );
  }

  String _getEncounterDisplayTitle(String type, Encounter? encounter) {
    switch (type.toLowerCase()) {
      case 'patient_registration':
        return 'Patient Registration';
      case 'consultation':
        return encounter?.doctor?.specialization != null
            ? '${encounter!.doctor!.specialization} Consultation'
            : 'Medical Consultation';
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
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildEncounterSummary(Encounter encounter) {
    String summary = '';

    switch (encounter.encounterType.toLowerCase()) {
      case 'patient_registration':
        summary = 'New patient registered';
        break;
      case 'consultation':
        if (encounter.diagnoses.isNotEmpty) {
          summary = 'Diagnosis: ${encounter.diagnoses.first.diagnosisName}';
        } else if (encounter.diagnosis.isNotEmpty) {
          summary = 'Diagnosis: ${encounter.diagnosis}';
        } else {
          summary = 'General consultation completed';
        }
        break;
      case 'dispensing':
        if (encounter.medications.isNotEmpty) {
          summary = '${encounter.medications.length} medication(s) dispensed';
        } else {
          summary = 'Medications dispensed';
        }
        break;
      case 'laboratory':
      case 'lab_test':
        if (encounter.labResults.isNotEmpty) {
          summary = '${encounter.labResults.length} test(s) completed';
        } else {
          summary = 'Laboratory tests performed';
        }
        break;
      case 'emergency':
        summary = 'Emergency care provided';
        break;
      case 'preventive':
        summary = 'Preventive health screening';
        break;
      default:
        summary = encounter.diagnosis.isNotEmpty
            ? encounter.diagnosis
            : 'Visit completed';
    }

    return Text(
      summary,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _getEncounterIcon(String type) {
    IconData iconData;
    Color color;

    switch (type.toLowerCase()) {
      case 'patient_registration':
        iconData = Icons.person_add;
        color = Colors.green;
        break;
      case 'consultation':
        iconData = Icons.medical_services;
        color = Colors.blue;
        break;
      case 'emergency':
        iconData = Icons.emergency;
        color = Colors.red;
        break;
      case 'preventive':
        iconData = Icons.shield;
        color = Colors.green;
        break;
      case 'specialist':
        iconData = Icons.person_search;
        color = Colors.purple;
        break;
      case 'laboratory':
      case 'lab_test':
        iconData = Icons.science;
        color = Colors.orange;
        break;
      case 'dispensing':
        iconData = Icons.medication;
        color = Colors.teal;
        break;
      case 'urgent_care':
        iconData = Icons.local_hospital;
        color = Colors.deepOrange;
        break;
      case 'follow_up':
        iconData = Icons.follow_the_signs;
        color = Colors.indigo;
        break;
      default:
        iconData = Icons.local_hospital;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final date =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d, y').format(date);
    }
  }

  Widget _buildHealthRecordsList() {
    return Consumer<HealthRecordProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchHealthRecords,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final records = provider.healthRecords;

        if (records.isEmpty) {
          return const Center(
            child: Text('No health records found'),
          );
        }

        // Filter records
        final filteredRecords = _selectedFilter == 'All'
            ? records
            : records
                .where((record) => record.type == _selectedFilter)
                .toList();

        if (filteredRecords.isEmpty) {
          return Center(
            child: Text('No ${_selectedFilter.toLowerCase()} records found'),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchHealthRecords,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredRecords.length,
            itemBuilder: (context, index) {
              final record = filteredRecords[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    record.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Date: ${_formatDate(record.date)}'),
                      const SizedBox(height: 4),
                      Text('Provider: ${record.provider}'),
                      const SizedBox(height: 4),
                      Text('Type: ${record.type}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_file, size: 16),
                          const SizedBox(width: 4),
                          Text('${record.attachments.length} attachment(s)'),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Find the corresponding encounter
                    final provider = Provider.of<HealthRecordProvider>(context,
                        listen: false);
                    final encounter = provider.encounters
                        .where((e) => e.id.toString() == record.id)
                        .firstOrNull;

                    if (encounter != null && encounter.id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EnhancedEncounterDetailScreen(
                              encounterId: encounter.id!),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              HealthRecordDetailScreen(recordId: record.id),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
