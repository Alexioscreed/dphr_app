import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_record_provider.dart';

class ShareDataScreen extends StatefulWidget {
  const ShareDataScreen({Key? key}) : super(key: key);

  @override
  State<ShareDataScreen> createState() => _ShareDataScreenState();
}

class _ShareDataScreenState extends State<ShareDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _purposeController = TextEditingController();

  bool _isLoading = false;
  bool _shareSuccess = false;
  List<String> _selectedRecords = [];
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientEmailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _shareData() async {
    if (_formKey.currentState!.validate() && _selectedRecords.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isLoading = false;
          _shareSuccess = true;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share data: $e')),
        );
      }
    } else if (_selectedRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one record to share')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Health Data'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: _shareSuccess ? _buildSuccessScreen() : _buildSharingForm(),
    );
  }

  Widget _buildSharingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share your health records with healthcare providers or family members',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recipient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientNameController,
              decoration: const InputDecoration(
                labelText: 'Recipient Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter recipient name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientEmailController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter recipient email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose of Sharing',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter purpose of sharing';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Expiry Date',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => _selectExpiryDate(context),
                ),
              ),
              controller: TextEditingController(
                text: '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Records to Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecordSelectionList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _shareData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
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
          ],
        ),
      ),
    );
  }

  Widget _buildRecordSelectionList() {
    return Consumer<HealthRecordProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${provider.error}',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }

        final records = provider.healthRecords;

        if (records.isEmpty) {
          return const Center(
            child: Text('No health records available to share'),
          );
        }

        return Card(
          elevation: 2,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isSelected = _selectedRecords.contains(record.id);

              return CheckboxListTile(
                title: Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${_formatDate(record.date)}'),
                    Text('Type: ${record.type}'),
                  ],
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedRecords.add(record.id);
                    } else {
                      _selectedRecords.remove(record.id);
                    }
                  });
                },
                activeColor: const Color(0xFF2196F3),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF2196F3),
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Records Shared Successfully',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You have successfully shared ${_selectedRecords.length} health record(s) with ${_recipientNameController.text}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${_recipientEmailController.text}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The shared records will expire on ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text('Back to Dashboard'),
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
