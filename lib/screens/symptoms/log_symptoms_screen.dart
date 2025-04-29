import 'package:flutter/material.dart';

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
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
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

  void _resetForm() {
    setState(() {
      _symptomsController.clear();
      _severityController.clear();
      _notesController.clear();
      _showConfirmation = false;
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
          if (_showConfirmation)
            _buildConfirmation()
          else
            _buildSymptomsForm(),
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
            color: Colors.green,
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
        const SizedBox(height: 24),
        const Text(
          'Recommendation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Health Insight',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHealthInsight(),
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
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Log Another Symptom'),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthInsight() {
    final symptom = _symptomsController.text.toLowerCase();
    final severity = int.tryParse(_severityController.text) ?? 3;

    String insight = '';
    Color insightColor = Colors.orange;

    if (symptom.contains('headache')) {
      if (severity >= 4) {
        insight = 'Your headache is severe. Consider consulting with a healthcare provider if it persists or is accompanied by other symptoms like fever, stiff neck, or vision changes.';
      } else {
        insight = 'For mild to moderate headaches, try rest, hydration, and over-the-counter pain relievers if appropriate. If headaches are recurring, consider tracking potential triggers.';
        insightColor = Colors.blue;
      }
    } else if (symptom.contains('fever')) {
      if (severity >= 4) {
        insight = 'Your fever is high. Consider consulting with a healthcare provider, especially if it persists for more than 3 days or is accompanied by severe symptoms.';
      } else {
        insight = 'For mild fever, ensure adequate rest and hydration. Monitor your temperature regularly and consider over-the-counter fever reducers if appropriate.';
        insightColor = Colors.blue;
      }
    } else if (symptom.contains('cough')) {
      if (severity >= 4) {
        insight = 'Your cough is severe. Consider consulting with a healthcare provider, especially if it\'s accompanied by shortness of breath, chest pain, or produces colored phlegm.';
      } else {
        insight = 'For mild to moderate cough, ensure adequate hydration and rest. Consider honey (if appropriate) or over-the-counter cough suppressants for comfort.';
        insightColor = Colors.blue;
      }
    } else {
      if (severity >= 4) {
        insight = 'Your symptoms are severe. Consider consulting with a healthcare provider for proper evaluation and treatment.';
      } else {
        insight = 'Monitor your symptoms and ensure adequate rest and hydration. If symptoms persist or worsen, consider consulting with a healthcare provider.';
        insightColor = Colors.blue;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          insight,
          style: TextStyle(
            color: insightColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Note: This is general information and not medical advice. Always consult with your healthcare provider for proper diagnosis and treatment.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
