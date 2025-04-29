import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/api_provider.dart';
import '../../utils/constants.dart';
import 'shared_record_detail_screen.dart';

class SharedRecordsScreen extends StatefulWidget {
  const SharedRecordsScreen({Key? key}) : super(key: key);

  @override
  State<SharedRecordsScreen> createState() => _SharedRecordsScreenState();
}

class _SharedRecordsScreenState extends State<SharedRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  String _selectedIdType = 'MRN';
  bool _isSearching = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _fetchSharedRecords() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSearching = true;
      });

      await Provider.of<ApiProvider>(context, listen: false).fetchSharedRecords(
        _idController.text,
        _selectedIdType,
      );

      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Health Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedIdType,
                    decoration: const InputDecoration(
                      labelText: 'ID Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ApiConstants.idTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIdType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'ID Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an ID number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _fetchSharedRecords,
                      child: _isSearching
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Search Records'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Shared Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ApiProvider>(
                builder: (context, apiProvider, child) {
                  if (apiProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (apiProvider.error.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${apiProvider.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              apiProvider.resetError();
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (apiProvider.sharedRecords == null) {
                    return const Center(
                      child: Text('No records found. Search to view shared records.'),
                    );
                  }

                  final results = apiProvider.sharedRecords!.results;

                  if (results == null || results.isEmpty) {
                    return const Center(
                      child: Text('No shared records found for this ID.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final record = results[index];
                      final visitDetails = record.visitDetails;
                      final diagnosisDetails = record.diagnosisDetails;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visit Date: ${visitDetails.visitDate}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Visit Type: ${visitDetails.visitType}'),
                              const SizedBox(height: 8),
                              Text(
                                'Diagnosis: ${diagnosisDetails != null && diagnosisDetails.isNotEmpty ? diagnosisDetails[0].diagnosis : 'N/A'}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Facility: ${record.facilityDetails.name}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SharedRecordDetailScreen(record: record),
                                        ),
                                      );
                                    },
                                    child: const Text('View Details'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

