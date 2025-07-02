import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/symptom.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vital_measurements_provider.dart';
import '../../services/api_service.dart';

class LogSymptomsScreen extends StatefulWidget {
  const LogSymptomsScreen({Key? key}) : super(key: key);

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _severityController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _showConfirmation = false;
  Symptom? _savedSymptom;

  @override
  void dispose() {
    _symptomsController.dispose();
    _severityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _logSymptom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create symptom object
        final symptom = Symptom(
          name: _symptomsController.text,
          severity: int.parse(_severityController.text),
          date: DateTime.now(),
          notes: _notesController.text,
        );

        // Log to terminal/console
        print('==========================================');
        print('NEW SYMPTOM LOGGED - ${DateTime.now().toString()}');
        print('==========================================');
        print('Symptom: ${symptom.name}');
        print('Severity: ${symptom.severity}/5');
        print('Notes: ${symptom.notes.isNotEmpty ? symptom.notes : 'None'}');
        print('Date: ${symptom.date.toString()}');
        print('==========================================');

        // Save to backend
        await _saveSymptomToBackend(symptom);

        // Add to provider for health analysis
        final vitalProvider =
            Provider.of<VitalMeasurementsProvider>(context, listen: false);
        await vitalProvider.addSymptom(symptom, context);

        setState(() {
          _savedSymptom = symptom;
          _showConfirmation = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log symptom: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveSymptomToBackend(Symptom symptom) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      if (authProvider.currentUser?.patientUuid == null) {
        throw Exception('User not authenticated');
      }
      final symptomData = {
        'name': symptom.name,
        'severity': symptom.severity,
        'recordedAt': symptom.date.toIso8601String(),
        'notes': symptom.notes,
      };

      final response = await apiService.post(
        'symptoms/patient-uuid/${authProvider.currentUser!.patientUuid}',
        symptomData,
      );

      if (response['error'] != null) {
        throw Exception(response['error']);
      }

      debugPrint('Symptom saved successfully: ${response.toString()}');
    } catch (e) {
      debugPrint('Error saving symptom to backend: $e');
      throw e; // Re-throw to show user feedback
    }
  }

  void _resetForm() {
    setState(() {
      _symptomsController.clear();
      _severityController.clear();
      _notesController.clear();
      _showConfirmation = false;
      _savedSymptom = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track your symptoms to monitor your health over time',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (_showConfirmation) _buildConfirmation() else _buildSymptomsForm(),
        ],
      ),
    );
  }

  Widget _buildSymptomsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptom Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _symptomsController,
            decoration: const InputDecoration(
              labelText: 'Symptom',
              hintText: 'e.g., Headache, Fever, Cough',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sick),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a symptom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _severityController,
            decoration: const InputDecoration(
              labelText: 'Severity (1-5)',
              hintText: 'e.g., 3',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.trending_up),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter severity';
              }

              final severity = int.tryParse(value);
              if (severity == null || severity < 1 || severity > 5) {
                return 'Please enter a number between 1 and 5';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Add any additional details',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _logSymptom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3), // Updated to blue
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                  : const Text('Log Symptom'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptom Logged Successfully',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2196F3)),
                    const SizedBox(width: 8),
                    Text(
                      'Symptom: ${_symptomsController.text}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Severity: ${_severityController.text}/5'),
                const SizedBox(height: 8),
                Text('Date: ${_formatDate(DateTime.now())}'),
                if (_notesController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes: ${_notesController.text}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Successfully Logged',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your symptom has been recorded and will be analyzed for health insights. Check your notifications for any health recommendations.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3), // Updated to blue
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Log Another Symptom'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
