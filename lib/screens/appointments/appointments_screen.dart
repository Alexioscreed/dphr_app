import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import 'appointment_detail_screen.dart';
import 'book_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    await appointmentProvider.fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2196F3), // Updated to blue
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2196F3), // Updated to blue
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList('upcoming'),
          _buildAppointmentsList('past'),
          _buildAppointmentsList('cancelled'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
          );
        },
        backgroundColor: const Color(0xFF2196F3), // Updated to blue
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsList(String type) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchAppointments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final appointments = provider.getAppointmentsByType(type);

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'upcoming' ? Icons.event_available : (type == 'past' ? Icons.event_busy : Icons.event_note),
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  type == 'upcoming'
                      ? 'No upcoming appointments'
                      : (type == 'past' ? 'No past appointments' : 'No cancelled appointments'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type == 'upcoming'
                      ? 'Book an appointment to get started'
                      : 'Your appointments will appear here',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                if (type == 'upcoming') ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3), // Updated to blue
                    ),
                    child: const Text('Book Appointment'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchAppointments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    'Dr. ${appointment.doctorName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Date: ${_formatDate(appointment.date)}'),
                      const SizedBox(height: 4),
                      Text('Time: ${_formatTime(appointment.time)}'),
                      const SizedBox(height: 4),
                      Text('Department: ${appointment.department}'),
                      const SizedBox(height: 4),
                      Text('Hospital: ${appointment.hospital}'),
                      const SizedBox(height: 8),
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
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AppointmentDetailScreen(appointmentId: appointment.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
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
        return const Color(0xFF2196F3); // Updated to blue
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
