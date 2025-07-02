import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import 'add_edit_doctor_screen.dart';

class DoctorDetailScreen extends StatelessWidget {
  static const routeName = '/doctor-detail';
  final Doctor doctor;

  const DoctorDetailScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditDoctorScreen(doctor: doctor),
                ),
              );
              if (result == true) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Text(
                  doctor.firstName[0] + doctor.lastName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(doctor),
            const SizedBox(height: 16),
            _buildContactCard(doctor),
            const SizedBox(height: 16),
            _buildActionButtons(context, doctor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Doctor doctor) {
    return Card(
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
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Specialization', doctor.specialization ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('Department', doctor.department ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('License Number', doctor.licenseNumber ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Doctor doctor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Email', doctor.email),
            const SizedBox(height: 8),
            _buildInfoRow('Phone', doctor.phoneNumber ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Doctor doctor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.phone),
          label: const Text('Contact Doctor'),
          onPressed: () {
            // Navigate to contact screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact feature coming soon')),
            );
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.message),
          label: const Text('Message'),
          onPressed: () {
            // Navigate to messaging screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messaging coming soon')),
            );
          },
        ),
      ],
    );
  }
}
