import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_record_provider.dart';
import '../../models/health_record.dart';

class HealthRecordDetailScreen extends StatelessWidget {
  final String recordId;

  const HealthRecordDetailScreen({
    Key? key,
    required this.recordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final healthRecordProvider = Provider.of<HealthRecordProvider>(context);
    final record = healthRecordProvider.getHealthRecordById(recordId);

    if (record == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Health Record Details'),
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
        ),
        body: const Center(
          child: Text('Record not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Record Details'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share record
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Print record
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecordHeader(record),
            const SizedBox(height: 24),
            _buildRecordDetails(record),
            const SizedBox(height: 24),
            _buildAttachments(record),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordHeader(HealthRecord record) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  record.provider,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                record.type,
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordDetails(HealthRecord record) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(record.description),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(HealthRecord record) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (record.attachments.isEmpty)
              const Text(
                'No attachments available',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: record.attachments.length,
                itemBuilder: (context, index) {
                  final attachment = record.attachments[index];
                  return _buildAttachmentItem(attachment);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(String fileName) {
    IconData iconData;
    Color iconColor;

    if (fileName.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
      iconData = Icons.image;
      iconColor = Colors.green;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      iconData = Icons.description;
      iconColor = Colors.blue;
    } else {
      iconData = Icons.insert_drive_file;
      iconColor = Colors.orange;
    }

    return ListTile(
      leading: Icon(iconData, color: iconColor),
      title: Text(fileName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Color(0xFF2196F3)),
            onPressed: () {
              // View file
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF2196F3)),
            onPressed: () {
              // Download file
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
