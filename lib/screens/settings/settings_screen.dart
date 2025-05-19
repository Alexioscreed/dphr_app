import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _biometricEnabled = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Arabic',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Account'),
          _buildAccountSettings(),
          const SizedBox(height: 24),

          _buildSectionHeader('Appearance'),
          _buildAppearanceSettings(themeProvider),
          const SizedBox(height: 24),

          _buildSectionHeader('Notifications'),
          _buildNotificationSettings(),
          const SizedBox(height: 24),

          _buildSectionHeader('Security'),
          _buildSecuritySettings(),
          const SizedBox(height: 24),

          _buildSectionHeader('Language'),
          _buildLanguageSettings(),
          const SizedBox(height: 24),

          _buildSectionHeader('About'),
          _buildAboutSettings(),
          const SizedBox(height: 24),

          _buildLogoutButton(authProvider),
        ],
      ),
    );
  }

  // Rest of the methods remain the same
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to profile screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Medical Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to medical info screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: const Text('Emergency Contacts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to emergency contacts screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(ThemeProvider themeProvider) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<AppThemeMode>(
              value: themeProvider.themeMode,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: const Text('System'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: const Text('Light'),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: const Text('Dark'),
                ),
              ],
              onChanged: (value) {
                if (value == AppThemeMode.system) {
                  themeProvider.setThemeMode(AppThemeMode.system);
                } else if (value == AppThemeMode.light) {
                  themeProvider.setThemeMode(AppThemeMode.light);
                } else if (value == AppThemeMode.dark) {
                  themeProvider.setThemeMode(AppThemeMode.dark);
                }
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Text Size'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to text size settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.email),
            title: const Text('Email Notifications'),
            value: _emailNotificationsEnabled,
            onChanged: _notificationsEnabled ? (value) {
              setState(() {
                _emailNotificationsEnabled = value;
              });
            } : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.sms),
            title: const Text('SMS Notifications'),
            value: _smsNotificationsEnabled,
            onChanged: _notificationsEnabled ? (value) {
              setState(() {
                _smsNotificationsEnabled = value;
              });
            } : null,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Reminder Settings'),
            trailing: const Icon(Icons.chevron_right),
            enabled: _notificationsEnabled,
            onTap: _notificationsEnabled ? () {
              // Navigate to reminder settings
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password screen
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: _languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About DPHR'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to about screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to help screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Terms & Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to terms screen
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Version'),
            trailing: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return ElevatedButton.icon(
      onPressed: authProvider.isLoading ? null : () {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Perform logout
                  Navigator.of(context).pop();
                  await authProvider.logout();

                  if (!mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
      icon: authProvider.isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Icon(Icons.logout),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
