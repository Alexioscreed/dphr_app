import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/doctor.dart';
import '../../services/doctor_service.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final Doctor? doctor;

  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.doctor != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final doctor = widget.doctor!;
    _firstNameController.text = doctor.firstName;
    _lastNameController.text = doctor.lastName;
    _emailController.text = doctor.email;
    _phoneNumberController.text = doctor.phoneNumber ?? '';
    _specializationController.text = doctor.specialization ?? '';
    _licenseNumberController.text = doctor.licenseNumber ?? '';
    _departmentController.text = doctor.department ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doctorService = Provider.of<DoctorService>(context, listen: false);
      final doctor = Doctor(
        id: _isEditing ? widget.doctor!.id : null,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        specialization: _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim().isEmpty
            ? null
            : _licenseNumberController.text.trim(),
        department: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
      );

      if (_isEditing) {
        await doctorService.updateDoctor(widget.doctor!.id!, doctor);
      } else {
        await doctorService.createDoctor(doctor);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Doctor updated successfully'
                : 'Doctor created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Doctor' : 'Add Doctor'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveDoctor,
              child: Text(
                _isEditing ? 'Update' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _specializationController,
                      decoration: const InputDecoration(
                        labelText: 'Specialization',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Cardiology, Pediatrics',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Emergency, Internal Medicine',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _saveDoctor,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                  _isEditing ? 'Update Doctor' : 'Create Doctor',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
