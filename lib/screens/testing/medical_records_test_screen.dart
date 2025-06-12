import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/medical_records_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class MedicalRecordsTestScreen extends StatefulWidget {
  const MedicalRecordsTestScreen({Key? key}) : super(key: key);

  @override
  State<MedicalRecordsTestScreen> createState() =>
      _MedicalRecordsTestScreenState();
}

class _MedicalRecordsTestScreenState extends State<MedicalRecordsTestScreen> {
  late MedicalRecordsService _medicalRecordsService;
  List<Map<String, dynamic>> _allEncounters = [];
  Map<String, dynamic>? _encounterSummary;
  String _testPatientUuid = '';
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize MedicalRecordsService with ApiService and AuthService from provider
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    _medicalRecordsService = MedicalRecordsService(apiService, authService);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records Test'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentUserCard(currentUser),
            const SizedBox(height: 16),
            _buildTestControlsCard(),
            const SizedBox(height: 16),
            if (_statusMessage.isNotEmpty) _buildStatusCard(),
            if (_encounterSummary != null) ...[
              const SizedBox(height: 16),
              _buildEncounterSummaryCard(),
            ],
            if (_allEncounters.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAllEncountersCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard(currentUser) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current User',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (currentUser != null) ...[
              Text('Name: ${currentUser.name}'),
              Text('Email: ${currentUser.email}'),
              Text('Patient UUID: ${currentUser.patientUuid ?? "Not set"}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (currentUser.patientUuid != null) {
                        setState(
                            () => _testPatientUuid = currentUser.patientUuid!);
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Use UUID'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _checkCurrentUserEncounters(currentUser.patientUuid),
                    icon: const Icon(Icons.search),
                    label: const Text('Check Encounters'),
                  ),
                ],
              ),
            ] else ...[
              const Text('No user logged in'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestControlsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Test Patient UUID',
                hintText: 'Enter a patient UUID to test',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _testPatientUuid = value,
              controller: TextEditingController(text: _testPatientUuid),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _testPatientEncounters(_testPatientUuid),
                  icon: const Icon(Icons.person_search),
                  label: const Text('Test Patient'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getAllEncounters,
                  icon: const Icon(Icons.list),
                  label: const Text('Get All Encounters'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testPlaceholderUUIDs,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Test Placeholders'),
                ),
              ],
            ),
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      color: _statusMessage.startsWith('Error')
          ? Colors.red.withOpacity(0.1)
          : Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _statusMessage.startsWith('Error')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.startsWith('Error')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Encounter Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Patient UUID', _encounterSummary!['patientUuid']),
            _buildInfoRow('Total Encounters',
                _encounterSummary!['totalEncounters'].toString()),
            if (_encounterSummary!['hasEncounters'] == true) ...[
              _buildInfoRow('Latest Encounter',
                  _encounterSummary!['latestEncounter'] ?? 'N/A'),
              _buildInfoRow('Earliest Encounter',
                  _encounterSummary!['earliestEncounter'] ?? 'N/A'),
              const SizedBox(height: 8),
              const Text('Encounters by Type:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              if (_encounterSummary!['encountersByType'] != null)
                ...(_encounterSummary!['encountersByType']
                        as Map<String, dynamic>)
                    .entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 2),
                          child: Text('${entry.key}: ${entry.value}'),
                        )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllEncountersCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Encounters (${_allEncounters.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allEncounters.length,
              itemBuilder: (context, index) {
                final encounter = _allEncounters[index];
                return ListTile(
                  dense: true,
                  title: Text(
                      '${encounter['encounterType']} - ${encounter['patientUuid']}'),
                  subtitle: Text(
                      '${encounter['location']} - ${encounter['encounterDateTime']}'),
                  trailing: Text('ID: ${encounter['encounterId']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _checkCurrentUserEncounters(String? patientUuid) async {
    if (patientUuid == null) {
      setState(() {
        _statusMessage = 'Error: No patient UUID available for current user';
      });
      return;
    }

    await _testPatientEncounters(patientUuid);
  }

  Future<void> _testPatientEncounters(String patientUuid) async {
    if (patientUuid.isEmpty) {
      setState(() {
        _statusMessage = 'Error: Please enter a patient UUID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _encounterSummary = null;
    });

    try {
      // Try to get medical records for the patient
      final medicalRecords = await _medicalRecordsService
          .getMedicalRecordsByPatientUuid(patientUuid);

      setState(() {
        _encounterSummary = {
          'patientUuid': patientUuid,
          'totalEncounters': medicalRecords['encounters']?.length ?? 0,
          'hasEncounters': (medicalRecords['encounters']?.length ?? 0) > 0,
          'patient': medicalRecords['patient'],
        };
        _statusMessage =
            'Success: Found ${_encounterSummary!['totalEncounters']} encounters for UUID: $patientUuid';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: Failed to test patient encounters - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAllEncounters() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final encounters =
          await _medicalRecordsService.getCurrentUserEncounters();

      setState(() {
        _allEncounters = encounters
            .map((e) => {
                  'encounterId': e.id,
                  'patientUuid':
                      'Unknown', // This would need to be added to the encounter model
                  'encounterType': e.encounterType,
                  'encounterDateTime': e.encounterDateTime.toIso8601String(),
                  'location': e.location,
                })
            .toList();
        _statusMessage = 'Success: Loaded ${encounters.length} encounters';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: Failed to get all encounters - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPlaceholderUUIDs() async {
    final placeholders = [
      'xxxxxxxxxx',
      'yyyyyyyyyy',
      'zzzzzzzzzz',
      'aaaaaaaaaa',
      'bbbbbbbbbb'
    ];

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      StringBuffer results = StringBuffer();
      for (String uuid in placeholders) {
        try {
          final medicalRecords =
              await _medicalRecordsService.getMedicalRecordsByPatientUuid(uuid);
          final hasEncounters = (medicalRecords['encounters']?.length ?? 0) > 0;
          results.writeln(
              '$uuid: ${hasEncounters ? "HAS ENCOUNTERS" : "NO ENCOUNTERS"}');
        } catch (e) {
          results.writeln('$uuid: ERROR - $e');
        }
      }

      setState(() {
        _statusMessage =
            'Placeholder UUID Test Results:\n${results.toString()}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: Failed to test placeholder UUIDs - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
