import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visits_health_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connectivity_service.dart';
import '../../models/patient_health_records.dart';
import '../../widgets/visits_health_widgets.dart';

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
    'This Month',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
    'Last Year',
    'Last 2 Years'
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
              ),
              body: _buildBody(visitsProvider, connectivityService),
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
          selectedFilter: _selectedFilter,
        );
      case 'timeline':
        return HealthTimelineView(
          healthRecords: healthRecords,
          selectedFilter: _selectedFilter,
        );
      case 'visits':
      default:
        return VisitsListView(
          visits: healthRecords.visits ?? [],
          selectedFilter: _selectedFilter,
        );
    }
  }
}
