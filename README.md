# DPHR Mobile App - Flutter

## Overview
Flutter mobile application for the Digital Personal Health Record system.

## Features
- User authentication (login/signup)
- Patient record management
- Password reset functionality
- Secure API communication

## Technology Stack
- Flutter SDK
- Dart programming language
- HTTP package for API calls
- Provider for state management
- SharedPreferences for local storage

## Project Structure
```
dphr_app/
├── lib/
│   ├── main.dart           # App entry point
│   ├── config/             # App configuration
│   ├── models/             # Data models
│   ├── providers/          # State management
│   ├── screens/            # UI screens
│   │   ├── auth/           # Authentication screens
│   │   ├── patients/       # Patient management screens
│   │   └── home/           # Home screens
│   ├── services/           # API services
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable widgets
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
└── pubspec.yaml           # Dependencies
```

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- An Android device or emulator

### Installation
1. Open the project in Android Studio
2. Install dependencies:
```bash
flutter pub get
```
3. Configure backend URL in `lib/config/app_config.dart`
4. Run the app:
```bash
flutter run
```

## Configuration

### Backend Connection
Update the API base URL in `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8080'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8080'; // For iOS simulator
}
```

### Running on Different Platforms

#### Android Emulator
- Use `http://10.0.2.2:8080` as base URL
- Start emulator from Android Studio

#### Physical Android Device
- Use your computer's IP address (e.g., `http://192.168.1.100:8080`)
- Ensure device and computer are on the same network

#### iOS Simulator
- Use `http://localhost:8080` as base URL
- Requires macOS and Xcode

## Screens

### Authentication
- **Login Screen**: User authentication
- **Register Screen**: New user registration
- **Forgot Password Screen**: Password reset request

### Main App
- **Home Screen**: Dashboard with patient overview
- **Patients List**: View all patients
- **Patient Details**: Individual patient information

## Development

### Adding New Features
1. Create models in `lib/models/`
2. Add services in `lib/services/`
3. Create screens in `lib/screens/`
4. Update providers if needed

### Testing
```bash
flutter test
```

### Building
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Troubleshooting

### Common Issues
1. **Connection refused**: Check backend is running and URL is correct
2. **Build errors**: Run `flutter clean && flutter pub get`
3. **Emulator issues**: Restart emulator and try again
