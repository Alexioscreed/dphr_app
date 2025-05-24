# Flutter App Setup Guide

## Overview
Step-by-step guide to set up and run the DPHR Flutter application in Android Studio.

## Prerequisites

### Required Software
- **Android Studio** (latest stable version)
- **Flutter SDK** (latest stable)
- **Dart SDK** (comes with Flutter)
- **Git** (for version control)

### Development Environment
- **Operating System**: Windows 10/11, macOS, or Linux
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 10GB free space

## Installation Steps

### 1. Install Android Studio
1. Download from [Android Studio Official Site](https://developer.android.com/studio)
2. Install with default settings
3. Install Android SDK (API level 30 or higher)

### 2. Install Flutter SDK
1. Download Flutter SDK from [Flutter Official Site](https://flutter.dev/docs/get-started/install)
2. Extract to a permanent location (e.g., `C:\flutter` on Windows)
3. Add Flutter to PATH environment variable

### 3. Verify Installation
```bash
flutter doctor
```
Resolve any issues shown in the doctor report.

### 4. Configure Android Studio
1. Install Flutter and Dart plugins
2. Configure Flutter SDK path in settings
3. Set up Android emulator or connect physical device

## Project Setup

### 1. Open Project in Android Studio
1. Launch Android Studio
2. Select "Open an existing project"
3. Navigate to and select the `dphr_app` folder
4. Wait for project to load and sync

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Backend Connection
Edit `lib/config/app_config.dart`:

```dart
class AppConfig {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  // For Physical Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:8080';
  
  // Other configuration
  static const int connectionTimeout = 30;
  static const String appName = 'DPHR';
}
```

## Running the Application

### 1. Start Backend Server
Ensure the Spring Boot backend is running:
```bash
cd backend/backend
mvn spring-boot:run
```

### 2. Set Up Android Device

#### Option A: Android Emulator
1. Open AVD Manager in Android Studio
2. Create new virtual device (Pixel 4, API 30+)
3. Start the emulator

#### Option B: Physical Android Device
1. Enable Developer Options on device
2. Enable USB Debugging
3. Connect via USB cable
4. Accept debugging permission on device

### 3. Run Flutter App
In Android Studio:
1. Select target device from device dropdown
2. Click the "Run" button (green triangle)
3. Or use command line: `flutter run`

## Project Structure

### Key Directories
```
dphr_app/lib/
├── main.dart                    # App entry point
├── config/
│   └── app_config.dart         # App configuration
├── models/
│   └── user.dart               # Data models
├── providers/
│   └── auth_provider.dart      # State management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   └── patients/
│       └── patients_screen.dart
├── services/
│   └── auth_service.dart       # API communication
├── utils/
│   └── constants.dart          # App constants
└── widgets/
    └── custom_widgets.dart     # Reusable components
```

## Development Workflow

### 1. Making Changes
1. Edit code in Android Studio
2. Save files (auto-saves enabled)
3. Hot reload: Press `r` in terminal or click hot reload button
4. Hot restart: Press `R` in terminal or click hot restart button

### 2. Testing Changes
1. Test on emulator first
2. Test on physical device
3. Test different screen sizes
4. Test network connectivity scenarios

### 3. Debugging
1. Use Android Studio debugger
2. Add breakpoints in code
3. Use `print()` statements for logging
4. Check device logs in Android Studio

## Configuration for Different Environments

### Development (Local Backend)
```dart
// app_config.dart
static const String baseUrl = 'http://10.0.2.2:8080'; // Emulator
static const String baseUrl = 'http://localhost:8080'; // iOS Simulator
```

### Testing (Network Backend)
```dart
// app_config.dart  
static const String baseUrl = 'http://your-server-ip:8080';
```

### Production
```dart
// app_config.dart
static const String baseUrl = 'https://your-domain.com/api';
```

## Troubleshooting

### Common Issues

#### 1. "Waiting for another flutter command to release the startup lock"
```bash
flutter clean
```

#### 2. Build Failures
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

#### 3. Network Connection Issues
- Check backend server is running
- Verify IP address/URL configuration
- Ensure device and computer are on same network (for physical devices)
- Check firewall settings

#### 4. Android License Issues
```bash
flutter doctor --android-licenses
```

#### 5. Gradle Build Issues
1. Delete `android/.gradle` folder
2. Delete `build` folder
3. Run `flutter clean`
4. Run `flutter pub get`

### Device-Specific Solutions

#### Android Emulator
- Ensure emulator has internet access
- Use `http://10.0.2.2:8080` for localhost
- Increase emulator RAM if sluggish

#### Physical Android Device
- Find computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Use `http://YOUR_IP:8080` format
- Ensure both devices on same WiFi network

#### iOS Simulator (Mac only)
- Use `http://localhost:8080`
- Ensure Xcode is installed
- Run `flutter doctor` for iOS setup

## Performance Optimization

### 1. Build Optimization
```bash
# Debug build (development)
flutter run

# Release build (testing)
flutter run --release

# Profile build (performance testing)
flutter run --profile
```

### 2. App Size Optimization
```bash
# Analyze app size
flutter build apk --analyze-size

# Build optimized APK
flutter build apk --release --shrink
```

## Best Practices

### 1. Development
- Use hot reload for quick iterations
- Test on multiple device sizes
- Handle network errors gracefully
- Implement proper loading states

### 2. Code Organization
- Follow Flutter/Dart naming conventions
- Use meaningful widget names
- Separate business logic from UI
- Implement proper error handling

### 3. Testing
- Test forgot password flow end-to-end
- Verify API connectivity
- Test offline scenarios
- Check different screen orientations

## Useful Commands

```bash
# Project management
flutter create .              # Initialize Flutter project
flutter pub get              # Install dependencies
flutter pub upgrade          # Update dependencies
flutter clean               # Clean build files

# Running and building
flutter run                 # Run in debug mode
flutter run --release       # Run in release mode
flutter build apk          # Build Android APK
flutter build appbundle    # Build Android App Bundle

# Analysis and testing
flutter analyze            # Static code analysis
flutter test              # Run unit tests
flutter doctor            # Check development environment
```

## Next Steps

After successful setup:
1. Test login/registration functionality
2. Test forgot password flow
3. Explore patient management features
4. Customize UI as needed
5. Add additional features

## Support

### Documentation
- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Android Studio Guide](https://developer.android.com/studio/intro)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter GitHub](https://github.com/flutter/flutter)
