import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vital_measurement.dart';
import '../../services/camera_scan_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vital_measurements_provider.dart';
import '../../services/api_service.dart';

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
        // Create vital measurement object
        final vital = VitalMeasurement(
          type: _selectedVitalType,
          value: '${_valueController.text} ${_getUnit()}',
          date: DateTime.now(),
          notes: _notesController.text,
        ); // Save to backend
        await _saveVitalToBackend(vital);

        // Add to provider for health analysis
        final vitalProvider =
            Provider.of<VitalMeasurementsProvider>(context, listen: false);
        await vitalProvider.addMeasurement(vital, context);

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
  Future<void> _saveVitalToBackend(VitalMeasurement vital) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      if (authProvider.currentUser?.patientUuid == null) {
        throw Exception('User not authenticated');
      }

      final vitalData = {
        'type': vital.type,
        'value': vital.value,
        'recordedAt': vital.date.toIso8601String(),
        'notes': vital.notes,
      };

      final response = await apiService.post(
        'vital-signs/patient-uuid/${authProvider.currentUser!.patientUuid}',
        vitalData,
      );

      if (response['error'] != null) {
        throw Exception(response['error']);
      }
      
      debugPrint('Vital saved successfully: ${response.toString()}');
    } catch (e) {
      debugPrint('Error saving vital to backend: $e');
      throw e; // Re-throw to show user feedback
    }
  }

  Future<void> _scanValue() async {
    try {
      final scannedValue =
          await CameraScanService.showScanDialog(context, _selectedVitalType);
      if (scannedValue != null && scannedValue.isNotEmpty) {
        setState(() {
          _valueController.text = scannedValue;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning value: ${e.toString()}')),
      );
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
          if (_showConfirmation) _buildConfirmation() else _buildVitalsForm(),
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
          Row(
            children: [
              Expanded(
                child: TextFormField(
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
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _scanValue,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  tooltip: 'Scan $_selectedVitalType',
                ),
              ),
            ],
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
                  'Your vital measurement has been recorded and will be analyzed for health insights. Check your notifications for any health recommendations.',
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
            child: const Text('Log Another Vital'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
