import 'package:flutter/material.dart';
import '../health_records/health_records_screen.dart';
import '../progress/health_progress_screen.dart';
import '../settings/settings_screen.dart';
import '../shared_records/shared_records_screen.dart';
import '../../widgets/notification_badge.dart';
import '../appointments/appointments_screen.dart';
import '../appointments/book_appointment_screen.dart';
import '../sharing/share_data_screen.dart';
import '../log_section_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const HealthRecordsScreen(),
    const LogSectionScreen(), // Updated to use the new LogSectionScreen
    const HealthProgressScreen(),
    const AppointmentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DPHR Dashboard',
          style: TextStyle(
            color: Color(0xFF2196F3), // Updated to blue
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          NotificationBadge(
            count: 3,
            onTap: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SharedRecordsScreen()),
              );
            },
            tooltip: 'Shared Records',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            selectedItemColor: const Color(0xFF2196F3), // Fresh blue color that works well in both modes
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_shared),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
          ],
        ),
      ),
    );
  }
}

// Rest of the DashboardHomeScreen class remains unchanged
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserGreeting(),
          const SizedBox(height: 24),
          _buildHealthSummary(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildUserGreeting() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF1976D2),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, John Doe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Last check-up: 15 May 2023',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.favorite,
                title: 'Heart Rate',
                value: '72 bpm',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.local_fire_department,
                title: 'Blood Pressure',
                value: '120/80',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.bloodtype,
                title: 'Glucose',
                value: '95 mg/dL',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.monitor_weight,
                title: 'Weight',
                value: '75 kg',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // Updated to match the number of activities
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              List<Map<String, dynamic>> activities = [
                {
                  'icon': Icons.medical_services,
                  'title': 'Doctor Recommendation',
                  'description': 'See a Cardiologist for your chest pain',
                  'time': 'Just now',
                  'color': Colors.red,
                  'isRecommendation': true,
                  'specialty': 'Cardiologist',
                  'reason': 'Chest Pain (Severity: 4/5)',
                },
                {
                  'icon': Icons.medication,
                  'title': 'Medication Reminder',
                  'description': 'Take Metformin 500mg',
                  'time': '2 hours ago',
                  'color': Colors.blue,
                  'isRecommendation': false,
                },
                {
                  'icon': Icons.local_hospital,
                  'title': 'Doctor Appointment',
                  'description': 'Dr. Smith - Cardiology',
                  'time': 'Yesterday',
                  'color': Colors.green,
                  'isRecommendation': false,
                },
              ];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: activities[index]['color'],
                  child: Icon(
                    activities[index]['icon'],
                    color: Colors.white,
                  ),
                ),
                title: Text(activities[index]['title']),
                subtitle: Text(activities[index]['description']),
                trailing: activities[index]['isRecommendation'] == true
                    ? ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookAppointmentScreen(
                          recommendedSpecialty: activities[index]['specialty'],
                          symptomReason: activities[index]['reason'],
                        ),
                      ),
                    );
                  },
                  child: const Text('Book'),
                )
                    : Text(
                  activities[index]['time'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24), // Increased spacing
        // Fixed height container for quick actions
        SizedBox(
          height: 120, // Increased height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changed to spaceEvenly for better distribution
            children: [
              _buildActionButton(
                icon: Icons.add_circle,
                label: 'Log\nHealth',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LogSectionScreen()),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.calendar_today,
                label: 'Appointments',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.medication,
                label: 'Medications',
                onTap: () {
                  // Navigate to medications
                },
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share\nData',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ShareDataScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF1976D2),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10), // Increased spacing
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2, // Added line height for better text spacing
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
