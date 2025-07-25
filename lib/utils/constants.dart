class ApiConstants {
  // Base URL for the Health Data Universal API
  static const String baseUrl = 'https://api.hdu.example.go.tz';

  // HFR Code for this facility
  static const String hfrCode = '109601-5';

  // Facility name
  static const String facilityName = 'DPHR Health Facility';

  // API credentials - These should be moved to environment configuration
  // TODO: Implement secure credential storage for production
  static const String apiUsername =
      String.fromEnvironment('HDU_API_USERNAME', defaultValue: 'api_username');
  static const String apiPassword =
      String.fromEnvironment('HDU_API_PASSWORD', defaultValue: 'api_password');

  // ID Types
  static const List<String> idTypes = ['MRN', 'NIDA', 'HCRCODE', 'NHIF'];

  // Visit Types
  static const List<String> visitTypes = [
    'General',
    'Emergency',
    'Follow-up',
    'Referral',
    'Antenatal',
    'Postnatal',
    'Vaccination',
    'Chronic Care',
  ];
}
