class ApiConstants {
  // Base URL for the Health Data Universal API
  static const String baseUrl = 'https://api.hdu.example.go.tz';

  // HFR Code for this facility
  static const String hfrCode = '109601-5';

  // Facility name
  static const String facilityName = 'DPHR Health Facility';

  // API credentials (these would typically be stored securely)
  static const String apiUsername = 'api_username';
  static const String apiPassword = 'api_password';

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

  // Diagnosis Certainty
  static const List<String> diagnosisCertainty = [
    'CONFIRMED',
    'PRESUMED',
    'PROVISIONAL',
    'DIFFERENTIAL',
  ];

  // Referral Status
  static const List<String> referralStatus = [
    'PENDING',
    'ACCEPTED',
    'REJECTED',
    'COMPLETED',
    'CANCELLED',
  ];
}

