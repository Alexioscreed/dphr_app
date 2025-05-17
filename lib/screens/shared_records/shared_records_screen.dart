import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/api_provider.dart';
import 'shared_record_detail_screen.dart';
import '../../models/shared_record.dart';

class SharedRecordsScreen extends StatefulWidget {
  const SharedRecordsScreen({Key? key}) : super(key: key);

  @override
  State<SharedRecordsScreen> createState() => _SharedRecordsScreenState();
}

class _SharedRecordsScreenState extends State<SharedRecordsScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSharedRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSharedRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      await apiProvider.fetchSharedRecords();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch shared records: $e')),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<SharedRecord> _getFilteredRecords(List<SharedRecord> records) {
    if (_searchQuery.isEmpty) {
      return records;
    }

    return records.where((record) {
      return record.recipientName.toLowerCase().contains(_searchQuery) ||
          record.recipientEmail.toLowerCase().contains(_searchQuery) ||
          record.recordType.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final apiProvider = Provider.of<ApiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Records'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by recipient, email, or record type',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
                    : null,
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: _buildRecordsList(apiProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to share record screen
        },
        backgroundColor: const Color(0xFF2196F3), // Blue color
        child: const Icon(Icons.share),
      ),
    );
  }

  Widget _buildRecordsList(ApiProvider apiProvider) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (apiProvider.error.isNotEmpty) {
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
              'Error: ${apiProvider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                apiProvider.resetError();
                _fetchSharedRecords();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredRecords = _getFilteredRecords(apiProvider.sharedRecords);

    if (filteredRecords.isEmpty) {
      return const Center(
        child: Text(
          'No shared records found',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSharedRecords,
      child: ListView.builder(
        itemCount: filteredRecords.length,
        itemBuilder: (context, index) {
          final record = filteredRecords[index];
          return _buildRecordCard(record);
        },
      ),
    );
  }

  Widget _buildRecordCard(SharedRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          record.recipientName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Email: ${record.recipientEmail}'),
            const SizedBox(height: 4),
            Text('Record Type: ${record.recordType}'),
            const SizedBox(height: 4),
            Text('Shared Date: ${_formatDate(record.sharedDate)}'),
            const SizedBox(height: 4),
            Text(
              'Status: ${record.status}',
              style: TextStyle(
                color: record.status == 'Active' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SharedRecordDetailScreen(recordId: record.id),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
