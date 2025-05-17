import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final appointment = appointmentProvider.getAppointmentById(widget.appointmentId);

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Details'),
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
        ),
        body: const Center(
          child: Text('Appointment not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppointmentCard(appointment),
            const SizedBox(height: 24),
            _buildDoctorCard(appointment),
            const SizedBox(height: 24),
            _buildLocationCard(appointment),
            const SizedBox(height: 24),
            _buildNotesCard(appointment),
            const SizedBox(height: 24),
            _buildActionButtons(appointment),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.event,
                  color: Color(0xFF2196F3),
                  size: 28,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appointment.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        appointment.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(appointment.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(appointment.time),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Appointment appointment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF2196F3),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${appointment.doctorName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.department,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Call doctor
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Message doctor
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Appointment appointment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF2196F3),
                  size: 28,
                ),
                const SizedBox(width: 16),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              appointment.hospital,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '123 Medical Center Drive, City, State 12345',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Open maps
                },
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2196F3),
                  side: const BorderSide(color: Color(0xFF2196F3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Appointment appointment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.note,
                  color: Color(0xFF2196F3),
                  size: 28,
                ),
                const SizedBox(width: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              appointment.notes.isEmpty ? 'No notes available' : appointment.notes,
              style: TextStyle(
                color: appointment.notes.isEmpty ? Colors.grey : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Appointment appointment) {
    final bool isPast = appointment.date.isBefore(DateTime.now());
    final bool isCancelled = appointment.status == 'Cancelled';

    if (isPast || isCancelled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Book new appointment
            Navigator.pop(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Book New Appointment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Reschedule appointment
            },
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Reschedule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _cancelAppointment(appointment.id),
            icon: _isLoading
                ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.cancel),
            label: Text(_isLoading ? 'Cancelling...' : 'Cancel Appointment'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _cancelAppointment(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final success = await appointmentProvider.cancelAppointment(id);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment: ${appointmentProvider.error}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel appointment: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2196F3);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rescheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
