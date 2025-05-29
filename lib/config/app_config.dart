class AppConfig {
  // Server configuration
  // Change this to your computer's IP address when testing on physical devices
  static const String serverIP = '10.142.192.54';
  static const int serverPort = 8080;

  // API URLs
  static String get baseApiUrl => 'http://$serverIP:$serverPort/api';

  // Other configuration settings can be added here
  static const bool enableDebugLogs = true;
  static const int connectionTimeout = 10; // seconds
}
