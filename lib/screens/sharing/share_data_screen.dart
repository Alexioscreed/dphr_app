import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visits_health_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/email_service.dart';

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
  String? _selectedVisitId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVisits();
    });
  }

  Future<void> _fetchVisits() async {
    final visitsProvider =
        Provider.of<VisitsHealthProvider>(context, listen: false);
    if (!visitsProvider.isLoading && visitsProvider.healthRecords == null) {
      await visitsProvider.fetchMyHealthRecords();
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientEmailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _shareData() async {
    if (_formKey.currentState!.validate() && _selectedVisitId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final visitsProvider =
            Provider.of<VisitsHealthProvider>(context, listen: false);
        final visits = visitsProvider.healthRecords?.visits ?? [];

        // Find the selected visit
        final selectedVisit = visits.firstWhere(
          (visit) => visit.visitUuid == _selectedVisitId,
          orElse: () => throw Exception('Selected visit not found'),
        );

        // Get patient demographics
        final demographics = visitsProvider.healthRecords?.demographics;
        if (demographics == null) {
          throw Exception('Patient demographics not available');
        }

        // Generate PDF for the visit
        final pdfService = PdfService();
        final pdfPath = await pdfService.generateVisitPdf(
          visit: selectedVisit,
          demographics: demographics,
          appName: 'DPHR - Digital Personal Health Records',
        );

        // Get email service from provider
        final emailService = Provider.of<EmailService>(context, listen: false);

        // Format visit date for subject line
        String visitDate = 'Unknown date';
        if (selectedVisit.startDate != null) {
          try {
            final date = DateTime.parse(selectedVisit.startDate!);
            visitDate = '${date.day}/${date.month}/${date.year}';
          } catch (e) {
            visitDate = selectedVisit.startDate!;
          }
        }

        final visitType = selectedVisit.visitType ?? 'Visit';
        final subject = 'DPHR - $visitType Summary ($visitDate)';

        final message = '''
Dear ${_recipientNameController.text},

The patient has shared their health visit summary with you through the DPHR app.
Purpose of sharing: ${_purposeController.text}

This is an automated message. Please do not reply to this email.

Regards,
DPHR Team
''';

        // Send email with attachment
        final emailSent = await emailService.sendEmailWithAttachment(
          recipientEmail: _recipientEmailController.text,
          recipientName: _recipientNameController.text,
          subject: subject,
          message: message,
          pdfFilePath: pdfPath,
          purpose: _purposeController.text,
        );

        if (!emailSent) {
          throw Exception('Failed to send email to recipient');
        }

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
    } else if (_selectedVisitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a visit to share')),
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
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
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
            const SizedBox(height: 24),
            const Text(
              'Select Visit to Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildVisitSelectionList(),
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

  Widget _buildVisitSelectionList() {
    return Consumer<VisitsHealthProvider>(
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

        final visits = provider.healthRecords?.visits ?? [];

        if (visits.isEmpty) {
          return const Center(
            child: Text('No visits available to share'),
          );
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final isSelected = visit.visitUuid == _selectedVisitId;

              // Format visit date
              String visitDate = 'Unknown date';
              if (visit.startDate != null) {
                try {
                  final date = DateTime.parse(visit.startDate!);
                  visitDate = '${date.day}/${date.month}/${date.year}';
                } catch (e) {
                  visitDate = visit.startDate!;
                }
              }

              return RadioListTile<String?>(
                tileColor: isSelected
                    ? Colors.blue.shade50
                    : Theme.of(context).canvasColor,
                title: Text(
                  visit.visitType != null && visit.visitType!.isNotEmpty
                      ? visit.visitType!
                      : 'Visit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: $visitDate'),
                    Text('Location: ${visit.location ?? 'Unknown'}'),
                  ],
                ),
                value: visit.visitUuid,
                groupValue: _selectedVisitId,
                onChanged: (value) {
                  setState(() {
                    _selectedVisitId = value;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
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
              'Visit Summary Shared Successfully',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You have successfully shared a visit summary with ${_recipientNameController.text}',
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
            const Text(
              'An email with the PDF attachment has been sent to the recipient.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
