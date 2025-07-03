import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'profile_information_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Account'),
          _buildAccountSettings(),
          const SizedBox(height: 24),
          _buildSectionHeader('Appearance'),
          _buildAppearanceSettings(themeProvider),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? const Color(0xFF90CAF9) : const Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: isDarkMode
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFF2196F3),
            ),
            title: Text(
              'Profile Information',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileInformationScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(ThemeProvider themeProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.brightness_6,
              color: isDarkMode
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFF2196F3),
            ),
            title: Text(
              'Theme Mode',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: DropdownButton<AppThemeMode>(
              value: themeProvider.themeMode,
              underline: const SizedBox(),
              dropdownColor:
                  isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              items: [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text(
                    'System',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text(
                    'Light',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text(
                    'Dark',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
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
        ],
      ),
    );
  }

  Widget _buildLanguageSettings() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.language,
              color: isDarkMode
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFF2196F3),
            ),
            title: Text(
              'Language',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              dropdownColor:
                  isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              items: _languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(
                    language,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info,
              color: isDarkMode
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFF2196F3),
            ),
            title: Text(
              'About DPHR',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
            onTap: () {
              _showAboutDialog(
                'About DPHR',
                'Digital Personal Health Records (DPHR) is a comprehensive healthcare management application designed to empower patients with secure access to their medical information. Our platform enables seamless communication between patients and healthcare providers while ensuring complete privacy and data security.',
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.help,
              color: isDarkMode
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFF2196F3),
            ),
            title: Text(
              'Help & Support',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
            onTap: () {
              _showAboutDialog(
                'Help & Support',
                'Need assistance? Our support team is here to help you make the most of DPHR. Contact us through the app for technical support, account issues, or general inquiries. We provide 24/7 customer support, comprehensive user guides, and video tutorials to ensure you have the best experience with our platform.',
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              color: isDarkMode
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFF2196F3),
            ),
            title: Text(
              'Terms & Privacy Policy',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
            onTap: () {
              _showAboutDialog(
                'Terms & Privacy Policy',
                'Your privacy and data security are our top priorities. DPHR complies with HIPAA regulations and international data protection standards. We use end-to-end encryption to protect your health information and never share your personal data with third parties without your explicit consent. Review our complete terms of service and privacy policy for detailed information about data handling and your rights.',
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.update,
              color: isDarkMode
                  ? const Color(0xFF90CAF9)
                  : const Color(0xFF2196F3),
            ),
            title: Text(
              'Version',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(String title, String content) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDarkMode ? Colors.grey[300] : Colors.black,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF90CAF9)
                    : const Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton.icon(
      onPressed: authProvider.isLoading
          ? null
          : () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor:
                      isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.black,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Perform logout
                        Navigator.of(context).pop();
                        await authProvider.logout();

                        if (!mounted) return;

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
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
