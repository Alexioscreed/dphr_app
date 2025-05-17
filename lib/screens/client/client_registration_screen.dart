import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/api_provider.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<ClientRegistrationScreen> createState() => _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isLoading = false;
  bool _registrationSuccess = false;
  String _clientId = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _registerClient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiProvider = Provider.of<ApiProvider>(context, listen: false);

        // Create client data map
        final Map<String, dynamic> clientData = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'idNumber': _idNumberController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'dateOfBirth': _dobController.text,
          'gender': _selectedGender,
        };

        // Register client
        final result = await apiProvider.registerClient(clientData);

        if (result) {
          // In a real app, you would get the client ID from the API response
          setState(() {
            _registrationSuccess = true;
            _clientId = 'CL${_idNumberController.text.substring(0, 4)}';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${apiProvider.error}')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Registration'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: _registrationSuccess ? _buildSuccessScreen() : _buildRegistrationForm(),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
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
                labelText: 'First Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'ID Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ID number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Male',
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => _selectDate(context),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select date of birth';
                }
                return null;
              },
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3), // Blue color
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
                    : const Text('Register Client'),
              ),
            ),
          ],
        ),
      ),
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
              color: Color(0xFF2196F3), // Blue color
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Registration Successful',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Client ID: $_clientId',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'The client has been successfully registered in the system.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3), // Blue color
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
