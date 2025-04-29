import 'package:flutter/material.dart';
import '../../models/vital_measurement.dart';

class LogVitalsScreen extends StatefulWidget {
  const LogVitalsScreen({Key? key}) : super(key: key);

  @override
  State<LogVitalsScreen> createState() => _LogVitalsScreenState();
}

class _LogVitalsScreenState extends State<LogVitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVitalType = 'Blood Pressure';
  bool _isLoading = false;
  bool _showConfirmation = false;
  VitalMeasurement? _savedVital;

  final List<String> _vitalTypes = [
    'Blood Pressure',
    'Heart Rate',
    'Temperature',
    'Blood Glucose',
    'Weight',
    'Oxygen Saturation',
  ];

  final Map<String, String> _unitMap = {
    'Blood Pressure': 'mmHg',
    'Heart Rate': 'bpm',
    'Temperature': '°C',
    'Blood Glucose': 'mg/dL',
    'Weight': 'kg',
    'Oxygen Saturation': '%',
  };

  final Map<String, String> _placeholderMap = {
    'Blood Pressure': '120/80',
    'Heart Rate': '72',
    'Temperature': '37.0',
    'Blood Glucose': '100',
    'Weight': '70',
    'Oxygen Saturation': '98',
  };

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getUnit() {
    return _unitMap[_selectedVitalType] ?? '';
  }

  String _getPlaceholder() {
    return _placeholderMap[_selectedVitalType] ?? '';
  }

  Future<void> _logVital() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Create vital measurement object
        final vital = VitalMeasurement(
          type: _selectedVitalType,
          value: '${_valueController.text} ${_getUnit()}',
          date: DateTime.now(),
          notes: _notesController.text,
        );

        // In a real app, you would save this to your provider or database

        setState(() {
          _savedVital = vital;
          _showConfirmation = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log vital: ${e.toString()}')),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _valueController.clear();
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
            'Track your vital measurements to monitor your health over time',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (_showConfirmation)
            _buildConfirmation()
          else
            _buildVitalsForm(),
        ],
      ),
    );
  }

  Widget _buildVitalsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vital Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedVitalType,
            decoration: const InputDecoration(
              labelText: 'Vital Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_heart),
            ),
            items: _vitalTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedVitalType = value!;
                _valueController.clear(); // Clear value when type changes
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: 'Value',
              hintText: 'e.g., ${_getPlaceholder()}',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.numbers),
              suffixText: _getUnit(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }

              // Special validation for blood pressure (format: 120/80)
              if (_selectedVitalType == 'Blood Pressure') {
                if (!RegExp(r'^\d+\/\d+$').hasMatch(value)) {
                  return 'Enter in format: 120/80';
                }
              }
              // Validation for other numeric values
              else if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                return 'Please enter a valid number';
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
              onPressed: _isLoading ? null : _logVital,
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
                  : const Text('Log Vital Measurement'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    if (_savedVital == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vital Measurement Logged Successfully',
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
                      'Type: ${_savedVital!.type}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Value: ${_savedVital!.value}'),
                const SizedBox(height: 8),
                Text('Date: ${_formatDate(_savedVital!.date)}'),
                if (_savedVital!.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes: ${_savedVital!.notes}'),
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
            child: const Text('Log Another Vital'),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthInsight() {
    if (_savedVital == null) return const SizedBox.shrink();

    // Generate insights based on vital type and value
    String insight = '';
    bool isNormal = true;

    switch (_savedVital!.type) {
      case 'Blood Pressure':
        final parts = _savedVital!.value.split(' ')[0].split('/');
        final systolic = int.tryParse(parts[0]) ?? 0;
        final diastolic = int.tryParse(parts[1]) ?? 0;

        if (systolic < 90 || diastolic < 60) {
          insight = 'Your blood pressure is lower than the normal range (90/60 - 120/80 mmHg). Consider consulting with your healthcare provider.';
          isNormal = false;
        } else if (systolic > 120 || diastolic > 80) {
          if (systolic > 140 || diastolic > 90) {
            insight = 'Your blood pressure is high (above 140/90 mmHg). It\'s recommended to consult with your healthcare provider.';
            isNormal = false;
          } else {
            insight = 'Your blood pressure is slightly elevated. Consider lifestyle changes like reducing salt intake and regular exercise.';
            isNormal = false;
          }
        } else {
          insight = 'Your blood pressure is within the normal range (90/60 - 120/80 mmHg). Keep up the good work!';
        }
        break;

      case 'Heart Rate':
        final rate = int.tryParse(_savedVital!.value.split(' ')[0]) ?? 0;

        if (rate < 60) {
          insight = 'Your heart rate is lower than the typical resting range (60-100 bpm). If you\'re not an athlete, consider consulting with your healthcare provider.';
          isNormal = false;
        } else if (rate > 100) {
          insight = 'Your heart rate is higher than the typical resting range (60-100 bpm). Consider consulting with your healthcare provider if this persists.';
          isNormal = false;
        } else {
          insight = 'Your heart rate is within the normal resting range (60-100 bpm).';
        }
        break;

      case 'Temperature':
        final temp = double.tryParse(_savedVital!.value.split(' ')[0]) ?? 0;

        if (temp < 36.1) {
          insight = 'Your body temperature is below the normal range (36.1-37.2°C). Consider consulting with your healthcare provider if this persists.';
          isNormal = false;
        } else if (temp > 37.2) {
          if (temp > 38.0) {
            insight = 'You have a fever (above 38.0°C). Consider taking appropriate medication and consulting with your healthcare provider if it persists.';
            isNormal = false;
          } else {
            insight = 'Your body temperature is slightly elevated. Monitor for other symptoms and rest.';
            isNormal = false;
          }
        } else {
          insight = 'Your body temperature is within the normal range (36.1-37.2°C).';
        }
        break;

      case 'Blood Glucose':
        final glucose = int.tryParse(_savedVital!.value.split(' ')[0]) ?? 0;

        if (glucose < 70) {
          insight = 'Your blood glucose is below the normal fasting range (70-100 mg/dL). Consider consuming some carbohydrates and consulting with your healthcare provider.';
          isNormal = false;
        } else if (glucose > 100) {
          if (glucose > 126) {
            insight = 'Your blood glucose is high (above 126 mg/dL when fasting). It\'s recommended to consult with your healthcare provider.';
            isNormal = false;
          } else {
            insight = 'Your blood glucose is slightly elevated. Consider lifestyle changes like diet modification and regular exercise.';
            isNormal = false;
          }
        } else {
          insight = 'Your blood glucose is within the normal fasting range (70-100 mg/dL).';
        }
        break;

      case 'Oxygen Saturation':
        final saturation = int.tryParse(_savedVital!.value.split(' ')[0]) ?? 0;

        if (saturation < 95) {
          if (saturation < 90) {
            insight = 'Your oxygen saturation is significantly below normal (below 90%). Seek medical attention immediately.';
            isNormal = false;
          } else {
            insight = 'Your oxygen saturation is slightly below the normal range (95-100%). Consider consulting with your healthcare provider.';
            isNormal = false;
          }
        } else {
          insight = 'Your oxygen saturation is within the normal range (95-100%).';
        }
        break;

      default:
        insight = 'Continue monitoring your ${_savedVital!.type.toLowerCase()} regularly to track changes over time.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          insight,
          style: TextStyle(
            color: isNormal ? Colors.green : Colors.orange,
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
