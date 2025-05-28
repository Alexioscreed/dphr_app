import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/prescription.dart';
import '../../models/medication.dart';
import '../../services/prescription_service.dart';

class AddEditPrescriptionScreen extends StatefulWidget {
  static const routeName = '/add-edit-prescription';
  final Prescription? prescription;
  final int patientId;
  final int? encounterId;

  const AddEditPrescriptionScreen({
    Key? key,
    this.prescription,
    required this.patientId,
    this.encounterId,
  }) : super(key: key);

  @override
  State<AddEditPrescriptionScreen> createState() =>
      _AddEditPrescriptionScreenState();
}

class _AddEditPrescriptionScreenState extends State<AddEditPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _error = '';
  List<Medication> _medications = [];

  // Form controllers
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _refillsController = TextEditingController();

  int? _selectedMedicationId;
  String _selectedStatus = 'active';
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.prescription != null;

  final List<String> _statusOptions = ['active', 'completed', 'discontinued'];
  final List<String> _frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
    'Before meals',
    'After meals',
  ];

  @override
  void initState() {
    super.initState();
    _loadMedications();
    if (_isEditing) {
      _populateFormFields();
    }
  }

  void _populateFormFields() {
    final prescription = widget.prescription!;
    _dosageController.text = prescription.dosage;
    _frequencyController.text = prescription.frequency;
    _durationController.text = prescription.duration ?? '';
    _instructionsController.text = prescription.instructions ?? '';
    _quantityController.text = prescription.quantity?.toString() ?? '';
    _refillsController.text = prescription.refills?.toString() ?? '';
    _selectedMedicationId = prescription.medicationId;
    _selectedStatus = prescription.status ?? 'active';
    _startDate = prescription.startDate;
    _endDate = prescription.endDate;
  }

  Future<void> _loadMedications() async {
    try {
      // Note: You'll need to implement getMedications in MedicalRecordsService
      // For now, we'll create a placeholder
      setState(() {
        _medications = []; // Placeholder - implement actual medication loading
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load medications: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _quantityController.dispose();
    _refillsController.dispose();
    super.dispose();
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMedicationId == null) {
      setState(() {
        _error = 'Please select a medication';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prescriptionService =
          Provider.of<PrescriptionService>(context, listen: false);

      final prescription = Prescription(
        id: _isEditing ? widget.prescription!.id : null,
        encounterId:
            widget.encounterId ?? 0, // You may need to handle this differently
        medicationId: _selectedMedicationId!,
        patientId: widget.patientId,
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        duration: _durationController.text.trim(),
        instructions: _instructionsController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        quantity: int.tryParse(_quantityController.text.trim()),
        refills: int.tryParse(_refillsController.text.trim()),
        status: _selectedStatus,
        prescribedDate:
            _isEditing ? widget.prescription!.prescribedDate : DateTime.now(),
      );
      if (_isEditing) {
        await prescriptionService.updatePrescription(
            widget.prescription!.id!, prescription);
      } else {
        await prescriptionService.createPrescription(prescription);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save prescription: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Prescription' : 'Add Prescription'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Medication Selection (placeholder)
                    DropdownButtonFormField<int>(
                      value: _selectedMedicationId,
                      decoration: const InputDecoration(
                        labelText: 'Medication',
                        border: OutlineInputBorder(),
                      ),
                      items: _medications.map((medication) {
                        return DropdownMenuItem<int>(
                          value: medication.id,
                          child: Text(
                              medication.name ?? medication.medicationName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMedicationId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a medication';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _dosageController,
                      label: 'Dosage',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter dosage';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _frequencyController.text.isEmpty
                          ? null
                          : _frequencyController.text,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                      ),
                      items: _frequencyOptions.map((frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _frequencyController.text = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select frequency';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _durationController,
                      label: 'Duration (e.g., "7 days", "2 weeks")',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _instructionsController,
                      label: 'Instructions',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _quantityController,
                            label: 'Quantity',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _refillsController,
                            label: 'Refills',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDateField(
                      label: 'Start Date',
                      selectedDate: _startDate,
                      onDateSelected: (date) {
                        setState(() {
                          _startDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDateField(
                      label: 'End Date (Optional)',
                      selectedDate: _endDate,
                      onDateSelected: (date) {
                        setState(() {
                          _endDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _savePrescription,
                      child: Text(_isEditing
                          ? 'Update Prescription'
                          : 'Add Prescription'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
        );
        onDateSelected(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : 'Select date',
        ),
      ),
    );
  }
}
