import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_record_provider.dart';
import 'health_record_detail_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Examination', 'Laboratory', 'Vaccination', 'Dental', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchHealthRecords();
  }

  Future<void> _fetchHealthRecords() async {
    final healthRecordProvider = Provider.of<HealthRecordProvider>(context, listen: false);
    await healthRecordProvider.fetchHealthRecords();
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
            child: _buildHealthRecordsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add health record screen
        },
        backgroundColor: const Color(0xFF2196F3), // Updated to blue
        child: const Icon(Icons.add),
      ),
    );
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
              selectedColor: const Color(0xFF2196F3).withOpacity(0.2), // Updated to blue
              checkmarkColor: const Color(0xFF2196F3), // Updated to blue
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.black, // Updated to blue
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
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
            : records.where((record) => record.type == _selectedFilter).toList();

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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HealthRecordDetailScreen(recordId: record.id),
                      ),
                    );
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
