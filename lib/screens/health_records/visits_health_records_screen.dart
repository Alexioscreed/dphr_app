import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/visits_health_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connectivity_service.dart';
import '../../models/patient_health_records.dart';
import '../../widgets/visits_health_widgets.dart';
import '../enhanced_health_records_screen.dart';

class VisitsHealthRecordsScreen extends StatefulWidget {
  const VisitsHealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<VisitsHealthRecordsScreen> createState() =>
      _VisitsHealthRecordsScreenState();
}

class _VisitsHealthRecordsScreenState extends State<VisitsHealthRecordsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Outpatient',
    'Inpatient',
    'Emergency',
    'Specialist',
    'Laboratory',
    'Consultation'
  ];
  String _selectedView = 'visits'; // 'visits', 'timeline', 'summary'

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
    final visitsProvider =
        Provider.of<VisitsHealthProvider>(context, listen: false);
    await visitsProvider.fetchMyHealthRecords();
    await visitsProvider.testConnection();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        return Consumer<VisitsHealthProvider>(
          builder: (context, visitsProvider, child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Health Records'),
                backgroundColor:
                    isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                foregroundColor: isDarkMode ? Colors.white : Colors.black,
                actions: [
                  // Connection status indicator
                  if (visitsProvider.connectionStatus != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: visitsProvider.connectionStatus == 'Connected'
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              visitsProvider.connectionStatus == 'Connected'
                                  ? Icons.cloud_done
                                  : Icons.cloud_off,
                              size: 16,
                              color: Colors.white),
                          const SizedBox(width: 4),
                          Text('iCare: ${visitsProvider.connectionStatus}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  // Offline indicator
                  if (connectivityService.isOffline)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Offline',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  // Refresh button
                  IconButton(
                    onPressed: connectivityService.isOnline
                        ? () => visitsProvider.refreshHealthRecords()
                        : null,
                    icon: const Icon(Icons.refresh),
                    tooltip: connectivityService.isOnline
                        ? 'Refresh data'
                        : 'No internet connection',
                  ), // View toggle
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'enhanced') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const EnhancedHealthRecordsScreen(),
                          ),
                        );
                      } else {
                        setState(() {
                          _selectedView = value;
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'visits', child: Text('Visits View')),
                      const PopupMenuItem(
                          value: 'timeline', child: Text('Timeline View')),
                      const PopupMenuItem(
                          value: 'summary', child: Text('Summary View')),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'enhanced',
                        child: Row(
                          children: [
                            Icon(Icons.upgrade,
                                size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            const Text('Enhanced View'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.view_module),
                  ),
                ],
              ),
              body: _buildBody(visitsProvider, connectivityService),
              floatingActionButton:
                  _buildFloatingActionButton(context, visitsProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(VisitsHealthProvider visitsProvider,
      ConnectivityService connectivityService) {
    if (visitsProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your health records from iCare...'),
          ],
        ),
      );
    }

    if (visitsProvider.error.isNotEmpty) {
      return _buildErrorState(visitsProvider);
    }

    if (!visitsProvider.patientFound) {
      return _buildPatientNotFoundState();
    }

    if (visitsProvider.healthRecords == null) {
      return _buildNoDataState();
    }

    return _buildHealthRecordsContent(visitsProvider);
  }

  Widget _buildErrorState(VisitsHealthProvider visitsProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Health Records',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              visitsProvider.error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => visitsProvider.refreshHealthRecords(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientNotFoundState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Patient Not Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No patient records found in the iCare system with your name. Please contact your healthcare provider to ensure your records are properly linked.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Health Records',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No medical records found. Visit your healthcare provider to start building your medical history.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordsContent(VisitsHealthProvider visitsProvider) {
    final healthRecords = visitsProvider.healthRecords!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Demographics header
          DemographicsCard(patient: healthRecords.demographics!),

          // Filter and view controls
          _buildFilterControls(),

          // Main content area
          _buildMainContent(visitsProvider, healthRecords),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      VisitsHealthProvider visitsProvider, PatientHealthRecords healthRecords) {
    switch (_selectedView) {
      case 'summary':
        return HealthSummaryView(
          healthRecords: healthRecords,
        );
      case 'timeline':
        return HealthTimelineView(
          healthRecords: healthRecords,
        );
      case 'visits':
      default:
        return VisitsListView(
          visits: healthRecords.visits ?? [],
          selectedFilter: _selectedFilter,
        );
    }
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, VisitsHealthProvider visitsProvider) {
    return FloatingActionButton.extended(
      onPressed: () {
        _fetchHealthRecords();
      },
      tooltip: 'Refresh Health Records',
      icon: const Icon(Icons.refresh),
      label: const Text('Refresh'),
    );
  }
}
