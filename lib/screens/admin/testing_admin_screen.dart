import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/medical_records_service.dart';
import '../../services/api_service.dart';

class TestingAdminScreen extends StatefulWidget {
  const TestingAdminScreen({Key? key}) : super(key: key);

  @override
  State<TestingAdminScreen> createState() => _TestingAdminScreenState();
}

class _TestingAdminScreenState extends State<TestingAdminScreen> {
  late MedicalRecordsService _medicalRecordsService;
  List<Map<String, dynamic>> _allEncounters = [];
  Map<String, dynamic>? _encounterSummary;
  String _testPatientUuid = '';
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize MedicalRecordsService with ApiService from provider
    final apiService = Provider.of<ApiService>(context, listen: false);
    _medicalRecordsService = MedicalRecordsService(apiService);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Admin'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Info
            _buildCurrentUserCard(currentUser),
            const SizedBox(height: 20),
            
            // Test Controls
            _buildTestControlsCard(),
            const SizedBox(height: 20),
            
            // Status Message
            if (_statusMessage.isNotEmpty) ...[
              _buildStatusCard(),
              const SizedBox(height: 20),
            ],
            
            // Encounter Summary
            if (_encounterSummary != null) ...[
              _buildEncounterSummaryCard(),
              const SizedBox(height: 20),
            ],
            
            // All Encounters List
            if (_allEncounters.isNotEmpty) ...[
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
              'Current User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (currentUser != null) ...[
              _buildInfoRow('Name', currentUser.name),
              _buildInfoRow('Email', currentUser.email),
              _buildInfoRow('Patient UUID', currentUser.patientUuid ?? 'Not Set'),
              _buildInfoRow('MRN', currentUser.mrn ?? 'Not Set'),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (currentUser.patientUuid != null) {
                        Clipboard.setData(ClipboardData(text: currentUser.patientUuid!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Patient UUID copied to clipboard')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy UUID'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _checkCurrentUserEncounters(currentUser.patientUuid),
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
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testPatientEncounters(_testPatientUuid),
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
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      color: _statusMessage.contains('Error') ? Colors.red.shade100 : Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _statusMessage.contains('Error') ? Icons.error : Icons.check_circle,
                  color: _statusMessage.contains('Error') ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_statusMessage),
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
            _buildInfoRow('Total Encounters', _encounterSummary!['totalEncounters'].toString()),
            if (_encounterSummary!['hasEncounters'] == true) ...[
              _buildInfoRow('Latest Encounter', _encounterSummary!['latestEncounter']),
              _buildInfoRow('Earliest Encounter', _encounterSummary!['earliestEncounter']),
              const SizedBox(height: 8),
              const Text('Encounters by Type:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              ...(_encounterSummary!['encountersByType'] as Map<String, dynamic>)
                  .entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text('• ${entry.key}: ${entry.value}'),
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
              'All Encounters in File (${_allEncounters.length})',
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
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('${encounter['encounterType']} - ${encounter['patientUuid']}'),
                    subtitle: Text('${encounter['location']} - ${encounter['encounterDateTime']}'),
                    trailing: Text('ID: ${encounter['encounterId']}'),
                  ),
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
      // Check if encounters exist
      final hasEncounters = await _medicalRecordsService.hasEncountersInFile(patientUuid);
      
      // Get summary
      final summary = await _medicalRecordsService.getPatientEncountersSummaryFromFile(patientUuid);
      
      setState(() {
        _encounterSummary = summary;
        _statusMessage = hasEncounters 
            ? 'Success: Found ${summary?['totalEncounters'] ?? 0} encounters for UUID: $patientUuid'
            : 'Info: No encounters found for UUID: $patientUuid';
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
      final encounters = await _medicalRecordsService.getAllEncountersFromFile();
      
      setState(() {
        _allEncounters = encounters.map((e) => {
          'encounterId': e.id,
          'patientUuid': 'Unknown', // This would need to be added to the encounter model
          'encounterType': e.encounterType,
          'encounterDateTime': e.encounterDateTime.toIso8601String(),
          'location': e.location,
        }).toList();
        _statusMessage = 'Success: Loaded ${encounters.length} encounters from file';
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
    final placeholders = ['xxxxxxxxxx', 'yyyyyyyyyy', 'zzzzzzzzzz', 'aaaaaaaaaa', 'bbbbbbbbbb'];
    
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      StringBuffer results = StringBuffer();
      for (String uuid in placeholders) {
        final hasEncounters = await _medicalRecordsService.hasEncountersInFile(uuid);
        results.writeln('$uuid: ${hasEncounters ? "HAS ENCOUNTERS" : "NO ENCOUNTERS"}');
      }
      
      setState(() {
        _statusMessage = 'Placeholder UUID Test Results:\n${results.toString()}';
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
