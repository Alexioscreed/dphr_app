import 'package:flutter/material.dart';
import '../../models/health_record.dart';

class ShareDataScreen extends StatefulWidget {
  const ShareDataScreen({Key? key}) : super(key: key);

  @override
  State<ShareDataScreen> createState() => _ShareDataScreenState();
}

class _ShareDataScreenState extends State<ShareDataScreen> {
  bool _isLoading = true;
  List<HealthRecord> _records = [];
  List<HealthRecord> _selectedRecords = [];
  final _recipientController = TextEditingController();
  String _selectedDuration = '24 hours';
  bool _isSharing = false;

  final List<String> _durations = [
    '24 hours',
    '3 days',
    '7 days',
    '30 days',
    'Until revoked',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    // Simulate loading records from API
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _records = [
        HealthRecord(
          id: '1',
          title: 'Annual Check-up',
          date: DateTime(2023, 5, 15),
          provider: 'Dr. John Smith',
          type: 'Medical',
          description: 'Regular annual physical examination',
          attachments: ['Physical Exam Report', 'Vitals'],
        ),
        HealthRecord(
          id: '2',
          title: 'Blood Test Results',
          date: DateTime(2023, 4, 10),
          provider: 'City Lab',
          type: 'Lab Tests',
          description: 'Complete blood count and metabolic panel',
          attachments: ['CBC Results', 'Metabolic Panel'],
        ),
        HealthRecord(
          id: '3',
          title: 'Prescription - Metformin',
          date: DateTime(2023, 3, 22),
          provider: 'Dr. Sarah Johnson',
          type: 'Prescriptions',
          description: 'Metformin 500mg, twice daily',
          attachments: ['Prescription Details'],
        ),
        HealthRecord(
          id: '4',
          title: 'COVID-19 Vaccination',
          date: DateTime(2023, 2, 5),
          provider: 'City Hospital',
          type: 'Vaccinations',
          description: 'COVID-19 Booster Shot',
          attachments: ['Vaccination Certificate'],
        ),
        HealthRecord(
          id: '5',
          title: 'Dental Check-up',
          date: DateTime(2023, 1, 15),
          provider: 'Dr. Lisa Wong',
          type: 'Medical',
          description: 'Regular dental examination and cleaning',
          attachments: ['Dental X-Rays', 'Treatment Plan'],
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _shareRecords() async {
    if (_selectedRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one record to share')),
      );
      return;
    }

    if (_recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipient email')),
      );
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call your API to share the records

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Records shared successfully')),
      );

      // Clear selections
      setState(() {
        _selectedRecords = [];
        _recipientController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share records: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _toggleRecordSelection(HealthRecord record) {
    setState(() {
      if (_selectedRecords.contains(record)) {
        _selectedRecords.remove(record);
      } else {
        _selectedRecords.add(record);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Health Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with fixed padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select the records you want to share and enter the recipient\'s email',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),

            // Recipient section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recipient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _recipientController,
                    decoration: const InputDecoration(
                      hintText: 'Enter email address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Access Duration section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Access Duration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    items: _durations.map((duration) {
                      return DropdownMenuItem<String>(
                        value: duration,
                        child: Text(duration),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Records selection header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Select Records to Share',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Records list - using Expanded to prevent overflow
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  final isSelected = _selectedRecords.contains(record);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: CheckboxListTile(
                      title: Text(
                        record.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(record.date)} • ${record.provider}',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        _toggleRecordSelection(record);
                      },
                      activeColor: Theme.of(context).primaryColor,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  );
                },
              ),
            ),

            // Share button - fixed at bottom with padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSharing ? null : _shareRecords,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isSharing
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Share Records'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

