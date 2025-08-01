import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../health_records/visits_health_records_screen.dart';
import '../progress/health_progress_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/notification_badge.dart';
import '../sharing/share_data_screen.dart';
import '../log_section_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart' as notifications;
import '../../providers/vital_measurements_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const VisitsHealthRecordsScreen(),
    const LogSectionScreen(),
    const HealthProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    // Redirect to login if not authenticated
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'DPHR Dashboard',
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          Consumer<notifications.NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return NotificationBadge(
                count: notificationProvider.unreadCount,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              );
            },
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
            backgroundColor:
                isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            selectedItemColor: const Color(0xFF2196F3),
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
          ],
        ),
      ),
    );
  }
}

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  bool _isLoadingVitals = false;
  Map<String, String?> _latestVitals = {};
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadLatestVitals();
    _loadRecentActivities();
  }

  Future<void> _loadRecentActivities() async {
    try {
      final vitalProvider =
          Provider.of<VitalMeasurementsProvider>(context, listen: false);

      List<Map<String, dynamic>> activities = [];

      // Get recent vital measurements
      final recentVitals = vitalProvider.measurements.take(3).toList();
      for (var vital in recentVitals) {
        final now = DateTime.now();
        final difference = now.difference(vital.date);
        String timeAgo;

        if (difference.inDays > 0) {
          timeAgo =
              '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
        } else if (difference.inHours > 0) {
          timeAgo =
              '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
        } else {
          timeAgo =
              '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
        }

        activities.add({
          'icon': Icons.local_hospital,
          'title': 'Health Check',
          'description': 'Logged ${vital.type}: ${vital.value}',
          'time': timeAgo,
          'color': Colors.green,
          'isRecommendation': false,
        });
      }

      // Get recent symptoms
      final recentSymptoms = vitalProvider.symptoms.take(3).toList();
      for (var symptom in recentSymptoms) {
        final now = DateTime.now();
        final difference = now.difference(symptom.date);
        String timeAgo;

        if (difference.inDays > 0) {
          timeAgo =
              '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
        } else if (difference.inHours > 0) {
          timeAgo =
              '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
        } else {
          timeAgo =
              '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
        }

        activities.add({
          'icon': Icons.local_hospital,
          'title': 'Health Check',
          'description':
              'Logged symptom: ${symptom.name} (Severity: ${symptom.severity}/5)',
          'time': timeAgo,
          'color': Colors.green,
          'isRecommendation': false,
        });
      }

      // Sort by most recent first and take top 5
      activities
          .sort((a, b) => a['time'].toString().compareTo(b['time'].toString()));
      _recentActivities = activities.take(5).toList();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
    }
  }

  Future<void> _loadLatestVitals() async {
    setState(() {
      _isLoadingVitals = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);
      final vitalProvider =
          Provider.of<VitalMeasurementsProvider>(context, listen: false);

      if (authProvider.currentUser?.patientUuid != null) {
        final vitalTypes = [
          'Heart Rate',
          'Blood Pressure',
          'Blood Glucose',
          'Weight',
          'Temperature',
          'Oxygen Saturation'
        ];

        for (String type in vitalTypes) {
          try {
            final latest = await vitalProvider.fetchLatestMeasurementByType(
              authProvider.currentUser!.patientUuid!,
              type,
              apiService,
            );
            _latestVitals[type] = latest?.value;
          } catch (e) {
            _latestVitals[type] = null;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading latest vitals: $e');
    }

    setState(() {
      _isLoadingVitals = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserGreeting(context),
          const SizedBox(height: 24),
          _buildHealthSummary(),
          const SizedBox(height: 24),
          _buildRecentActivity(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildUserGreeting(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF1976D2),
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name ?? 'User'}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Health Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            if (_isLoadingVitals)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.favorite,
                title: 'Heart Rate',
                value: _latestVitals['Heart Rate'] ?? 'No data',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.local_fire_department,
                title: 'Blood Pressure',
                value: _latestVitals['Blood Pressure'] ?? 'No data',
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
                value: _latestVitals['Blood Glucose'] ?? 'No data',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.monitor_weight,
                title: 'Weight',
                value: _latestVitals['Weight'] ?? 'No data',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.thermostat,
                title: 'Temperature',
                value: _latestVitals['Temperature'] ?? 'No data',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.air,
                title: 'Oxygen Sat.',
                value: _latestVitals['Oxygen Saturation'] ?? 'No data',
                color: Colors.cyan,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
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
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Consumer<VitalMeasurementsProvider>(
      builder: (context, vitalProvider, child) {
        // Update recent activities when provider changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadRecentActivities();
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              child: _recentActivities.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.timeline,
                            size: 48,
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start logging your symptoms or vitals to see your health activity here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentActivities.length,
                      separatorBuilder: (context, index) => Divider(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      ),
                      itemBuilder: (context, index) {
                        final activity = _recentActivities[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: activity['color'],
                            child: Icon(
                              activity['icon'],
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            activity['title'],
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            activity['description'],
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            activity['time'],
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.grey[500] : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.add_circle,
                label: 'Log\nHealth',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const LogSectionScreen()),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.trending_up,
                label: 'Health\nProgress',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const HealthProgressScreen()),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share\nData',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const ShareDataScreen()),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                color: isDarkMode ? Colors.white : Colors.black,
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
