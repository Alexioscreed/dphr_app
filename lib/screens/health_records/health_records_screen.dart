import 'package:flutter/material.dart';
import '../../models/health_record.dart';
import 'health_record_detail_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  bool _isLoading = true;
  List<HealthRecord> _records = [];
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Medical', 'Lab Tests', 'Prescriptions', 'Vaccinations'];

  @override
  void initState() {
    super.initState();
    _loadRecords();
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

  List<HealthRecord> _getFilteredRecords() {
    if (_selectedFilter == 'All') {
      return _records;
    } else {
      return _records.where((record) => record.type == _selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRecordsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add record screen
        },
        backgroundColor: const Color(0xFF00796B), // Updated to match Dashboard primary color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == _filters[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = _filters[index];
                });
              },
              backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDarkMode ? Colors.white : Theme.of(context).primaryColor)
                    : (isDarkMode ? Colors.white : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordsList() {
    final filteredRecords = _getFilteredRecords();

    if (filteredRecords.isEmpty) {
      return const Center(
        child: Text(
          'No records found',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredRecords.length,
      padding: const EdgeInsets.all(16.0),
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
                Text('Provider: ${record.provider}'),
                Text('Type: ${record.type}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                    Text(
                      '${record.attachments.length} attachment(s)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HealthRecordDetailScreen(record: record),
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

