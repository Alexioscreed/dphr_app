import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/concept_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/concept.dart';
import '../../models/encounter.dart';

class ConceptTestScreen extends StatefulWidget {
  const ConceptTestScreen({Key? key}) : super(key: key);

  @override
  State<ConceptTestScreen> createState() => _ConceptTestScreenState();
}

class _ConceptTestScreenState extends State<ConceptTestScreen> {
  late ConceptService _conceptService;
  List<Concept> _concepts = [];
  List<Encounter> _encounters = [];
  bool _loading = false;
  String _status = 'Ready to test concept integration';
  Concept? _selectedConcept;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _conceptService = ConceptService(apiService);
  }

  Future<void> _testConceptSearch() async {
    setState(() {
      _loading = true;
      _status = 'Searching for concepts...';
    });

    try {
      // Test 1: Search for blood type concepts
      final bloodTypeConcepts = await _conceptService.searchConcepts(
        term: '38341003',
        source: 'SNOMED CT',
        limit: 5,
      );

      // Test 2: Search for general concepts
      final generalConcepts = await _conceptService.searchConcepts(limit: 10);

      setState(() {
        _concepts = [...bloodTypeConcepts, ...generalConcepts];
        _status = 'Found ${_concepts.length} concepts';
      });
    } catch (e) {
      setState(() {
        _status = 'Error searching concepts: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _testCurrentUserEncounters({String? conceptUuid}) async {
    setState(() {
      _loading = true;
      _status = conceptUuid != null
          ? 'Fetching patient encounters with concept...'
          : 'Fetching patient encounters without concept...';
    });

    try {
      // Get the current user's patient UUID from the auth service
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser?.patientUuid == null ||
          currentUser?.patientUuid?.isEmpty == true) {
        setState(() {
          _status = 'Error: No patient UUID found for current user';
          _loading = false;
        });
        return;
      }

      final encounters = await _conceptService.getPatientEncountersWithConcept(
        patientUuid: currentUser!.patientUuid!,
        conceptUuid: conceptUuid,
        fromDate: '2016-10-08',
      );

      setState(() {
        _encounters = encounters;
        _status = conceptUuid != null
            ? 'Found ${encounters.length} encounters with concept filtering'
            : 'Found ${encounters.length} total encounters';
      });
    } catch (e) {
      setState(() {
        _status = 'Error fetching encounters: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concept Integration Test'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        final currentUser = authService.currentUser;
                        return Text(
                          '${currentUser?.name ?? 'Unknown User'} - Concept Integration Test',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        final currentUser = authService.currentUser;
                        return Text(
                          'Patient UUID: ${currentUser?.patientUuid ?? 'Not Available'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $_status',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_loading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _testConceptSearch,
                            child: const Text('Search Concepts'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () => _testCurrentUserEncounters(),
                            child: const Text('Get All Encounters'),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedConcept != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _loading
                              ? null
                              : () => _testCurrentUserEncounters(
                                  conceptUuid: _selectedConcept!.uuid),
                          child: Text(
                              'Get Encounters with ${_selectedConcept!.display}'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Concepts List
            if (_concepts.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Found Concepts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_concepts.map((concept) => ListTile(
                            title: Text(concept.display),
                            subtitle: Text('UUID: ${concept.uuid}'),
                            trailing: _selectedConcept?.uuid == concept.uuid
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedConcept = concept;
                              });
                            },
                          ))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Encounters List
            if (_encounters.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Found Encounters (${_encounters.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_encounters.take(5).map((encounter) => Card(
                            color: Colors.green[50],
                            child: ListTile(
                              title: Text(encounter.encounterType.isEmpty
                                  ? 'Unknown Type'
                                  : encounter.encounterType),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Date: ${encounter.encounterDateTime.toString()}'),
                                  if (encounter.provider.isNotEmpty)
                                    Text('Provider: ${encounter.provider}'),
                                  if (encounter.diagnosis.isNotEmpty)
                                    Text('Diagnosis: ${encounter.diagnosis}'),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          ))),
                      if (_encounters.length > 5)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '... and ${_encounters.length - 5} more encounters',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Success Message
            if (_encounters.isNotEmpty && _selectedConcept != null) ...[
              Card(
                color: Colors.green[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '🎯 SUCCESS!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Concept integration is working!',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Successfully retrieved medical records using concept filtering.\nThis matches the iCare API format you requested.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
