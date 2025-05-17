import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/api_provider.dart';
import '../../models/shared_record.dart';

class SharedRecordDetailScreen extends StatefulWidget {
  final String recordId;

  const SharedRecordDetailScreen({
    Key? key,
    required this.recordId,
  }) : super(key: key);

  @override
  State<SharedRecordDetailScreen> createState() => _SharedRecordDetailScreenState();
}

class _SharedRecordDetailScreenState extends State<SharedRecordDetailScreen> {
  bool _isLoading = false;
  SharedRecord? _record;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final record = apiProvider.getSharedRecordById(widget.recordId);

      setState(() {
        _record = record;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Record Details'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty) {
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
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecord,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_record == null) {
      return const Center(
        child: Text(
          'Record not found',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecipientInfoCard(),
          const SizedBox(height: 16),
          _buildRecordDetailsCard(),
          const SizedBox(height: 16),
          _buildFilesCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildRecipientInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3), // Blue color
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _record!.recipientName),
            const SizedBox(height: 8),
            _buildInfoRow('Email', _record!.recipientEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3), // Blue color
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Record Type', _record!.recordType),
            const SizedBox(height: 8),
            _buildInfoRow('Shared Date', _formatDate(_record!.sharedDate)),
            const SizedBox(height: 8),
            _buildInfoRow('Expiry Date', _formatDate(_record!.expiryDate)),
            const SizedBox(height: 8),
            _buildInfoRow('Status', _record!.status,
                valueColor: _record!.status == 'Active' ? Colors.green : Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_record!.description),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3), // Blue color
              ),
            ),
            const SizedBox(height: 16),
            ..._record!.files.map((file) => _buildFileItem(file)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    IconData iconData;
    if (fileName.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf;
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
      iconData = Icons.image;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      iconData = Icons.description;
    } else {
      iconData = Icons.insert_drive_file;
    }

    return ListTile(
      leading: Icon(iconData, color: const Color(0xFF2196F3)), // Blue color
      title: Text(fileName),
      trailing: const Icon(Icons.download),
      onTap: () {
        // Download or view file
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading $fileName...')),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Share record
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing record...')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3), // Blue color
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Print record
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing record...')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3), // Blue color
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
