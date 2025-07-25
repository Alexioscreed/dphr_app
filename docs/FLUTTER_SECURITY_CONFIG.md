# Flutter Environment Configuration Guide

## Overview
This guide covers secure configuration management for the Flutter frontend of the DPHR application.

## Current Configuration Files

### 1. App Configuration (`lib/config/app_config.dart`)
Contains server connection settings that may need environment-specific values.

### 2. API Constants (`lib/utils/constants.dart`)
Contains API credentials and configuration that should be managed securely.

## Security Considerations for Flutter

### 1. Environment Variables in Flutter
Flutter supports compile-time environment variables using `--dart-define`:

```bash
flutter run --dart-define=HDU_API_USERNAME=actual_username --dart-define=HDU_API_PASSWORD=actual_password
```

### 2. Build Configuration
For different environments, you can create build scripts:

#### Development Build
```bash
flutter build apk --dart-define=ENVIRONMENT=development --dart-define=HDU_API_USERNAME=dev_user --dart-define=HDU_API_PASSWORD=dev_pass
```

#### Production Build
```bash
flutter build apk --dart-define=ENVIRONMENT=production --dart-define=HDU_API_USERNAME=prod_user --dart-define=HDU_API_PASSWORD=prod_pass
```

### 3. Secure Storage for Runtime Secrets
For sensitive data that needs to be stored on the device, use the `flutter_secure_storage` package:

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

Example usage:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> storeApiKey(String key) async {
    await _storage.write(key: 'api_key', value: key);
  }

  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'api_key');
  }
}
```

## Configuration Updates Made

### 1. Updated `constants.dart`
- Changed hardcoded credentials to use `String.fromEnvironment()`
- Added fallback default values for development
- Added TODO comments for production security

### 2. Recommendations for App Config
Consider updating `app_config.dart` to support environment-specific configurations:

```dart
class AppConfig {
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  // Server configuration based on environment
  static String get serverIP {
    switch (environment) {
      case 'production':
        return String.fromEnvironment('PROD_SERVER_IP', defaultValue: 'your-prod-server.com');
      case 'staging':
        return String.fromEnvironment('STAGING_SERVER_IP', defaultValue: 'staging-server.com');
      default:
        return String.fromEnvironment('DEV_SERVER_IP', defaultValue: '192.168.1.125');
    }
  }
  
  static int get serverPort {
    switch (environment) {
      case 'production':
        return int.fromEnvironment('PROD_SERVER_PORT', defaultValue: 443);
      case 'staging':
        return int.fromEnvironment('STAGING_SERVER_PORT', defaultValue: 8081);
      default:
        return int.fromEnvironment('DEV_SERVER_PORT', defaultValue: 8081);
    }
  }
}
```

## Security Best Practices for Flutter

### 1. Code Obfuscation
Enable code obfuscation for release builds:
```bash
flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>
```

### 2. Certificate Pinning
Implement certificate pinning for API communications:
```dart
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';

final dio = Dio();
dio.interceptors.add(CertificatePinningInterceptor(
  allowedSHAFingerprints: ['SHA_FINGERPRINT_OF_YOUR_SERVER'],
));
```

### 3. API Key Management
- Never hardcode API keys in source code
- Use environment variables during build time
- Consider server-side proxy for sensitive API calls
- Implement API key rotation

### 4. Local Data Security
- Use `flutter_secure_storage` for sensitive data
- Encrypt local databases if needed
- Clear sensitive data on app backgrounding

## Build Scripts

### Create Environment-Specific Build Scripts

#### `scripts/build-dev.bat` (Windows)
```batch
@echo off
flutter build apk --dart-define=ENVIRONMENT=development --dart-define=HDU_API_USERNAME=%DEV_HDU_USERNAME% --dart-define=HDU_API_PASSWORD=%DEV_HDU_PASSWORD%
```

#### `scripts/build-prod.bat` (Windows)
```batch
@echo off
flutter build apk --dart-define=ENVIRONMENT=production --dart-define=HDU_API_USERNAME=%PROD_HDU_USERNAME% --dart-define=HDU_API_PASSWORD=%PROD_HDU_PASSWORD% --obfuscate --split-debug-info=build/debug-info
```

#### `scripts/build-dev.sh` (Linux/Mac)
```bash
#!/bin/bash
flutter build apk --dart-define=ENVIRONMENT=development --dart-define=HDU_API_USERNAME=$DEV_HDU_USERNAME --dart-define=HDU_API_PASSWORD=$DEV_HDU_PASSWORD
```

#### `scripts/build-prod.sh` (Linux/Mac)
```bash
#!/bin/bash
flutter build apk --dart-define=ENVIRONMENT=production --dart-define=HDU_API_USERNAME=$PROD_HDU_USERNAME --dart-define=HDU_API_PASSWORD=$PROD_HDU_PASSWORD --obfuscate --split-debug-info=build/debug-info
```

## Environment Variables for Flutter Development

### Local Development
Set environment variables in your IDE or terminal:

#### VS Code (`launch.json`)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "DPHR App (Dev)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define=ENVIRONMENT=development",
        "--dart-define=HDU_API_USERNAME=dev_user",
        "--dart-define=HDU_API_PASSWORD=dev_pass"
      ]
    },
    {
      "name": "DPHR App (Prod)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define=ENVIRONMENT=production",
        "--dart-define=HDU_API_USERNAME=prod_user",
        "--dart-define=HDU_API_PASSWORD=prod_pass"
      ]
    }
  ]
}
```

### CI/CD Integration
For GitHub Actions or other CI/CD systems:

```yaml
- name: Build Flutter App
  run: |
    flutter build apk \
      --dart-define=ENVIRONMENT=production \
      --dart-define=HDU_API_USERNAME=${{ secrets.HDU_API_USERNAME }} \
      --dart-define=HDU_API_PASSWORD=${{ secrets.HDU_API_PASSWORD }}
  env:
    HDU_API_USERNAME: ${{ secrets.HDU_API_USERNAME }}
    HDU_API_PASSWORD: ${{ secrets.HDU_API_PASSWORD }}
```

## Recommended Security Packages

Add these packages to `pubspec.yaml` for enhanced security:

```yaml
dependencies:
  # Secure storage for sensitive data
  flutter_secure_storage: ^9.0.0
  
  # HTTP client with certificate pinning
  dio: ^5.3.2
  dio_certificate_pinning: ^4.1.0
  
  # Encryption for local data
  encrypt: ^5.0.1
  
  # Device security checks
  device_info_plus: ^9.1.0
  
  # Biometric authentication
  local_auth: ^2.1.6
```

## Testing with Environment Variables

### Unit Tests
```dart
void main() {
  testWidgets('Test with environment variables', (WidgetTester tester) async {
    // Set test environment variables
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'test');
    
    // Your test code here
  });
}
```

### Integration Tests
Run integration tests with specific environment:
```bash
flutter test integration_test/app_test.dart --dart-define=ENVIRONMENT=test
```

## Monitoring and Logging

### Secure Logging
```dart
import 'dart:developer' as developer;

class SecureLogger {
  static void log(String message, {String? name, Object? error}) {
    // Only log in development
    if (kDebugMode) {
      developer.log(message, name: name, error: error);
    }
  }
  
  static void logSecure(String message, {String? name}) {
    // Never log sensitive information
    if (kDebugMode && !message.contains('password') && !message.contains('token')) {
      developer.log(message, name: name);
    }
  }
}
```

## Compliance Considerations

### Data Protection
- Implement proper data encryption for local storage
- Use secure communication protocols (HTTPS/TLS)
- Implement proper session management
- Clear sensitive data from memory when not needed

### Medical Data Security (HIPAA)
- Encrypt all medical data in transit and at rest
- Implement proper access controls
- Log all access to medical data
- Implement automatic logout for inactive sessions

## Next Steps

1. **Implement Secure Storage**: Add `flutter_secure_storage` for runtime secrets
2. **Update App Config**: Make configuration environment-aware
3. **Add Certificate Pinning**: Implement for production API calls
4. **Create Build Scripts**: Automate environment-specific builds
5. **Implement Logging**: Add secure logging throughout the app
6. **Add Security Tests**: Test security implementations
7. **Documentation**: Update deployment documentation with security procedures
