import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/health_record_provider.dart';
import 'providers/visits_health_provider.dart';
import 'providers/notification_provider.dart' as notifications;
import 'providers/api_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/vital_measurements_provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/medical_records_service.dart';
import 'services/health_records_service.dart';
import 'services/doctor_service.dart';
import 'services/prescription_service.dart';
import 'services/connectivity_service.dart';
import 'services/cache_service.dart';
import 'services/email_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  final cacheService = CacheService();
  await cacheService.init();

  runApp(
    MultiProvider(
      providers: [
        // Initialize ConnectivityService first
        ChangeNotifierProvider<ConnectivityService>.value(
          value: connectivityService,
        ),
        // Initialize CacheService
        Provider<CacheService>.value(
          value: cacheService,
        ),
        // Initialize AuthService first as it's a dependency for others
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        // Initialize ApiService with AuthService dependency
        ProxyProvider<AuthService, ApiService>(
          update: (context, authService, previous) => ApiService(authService),
        ), // Initialize MedicalRecordsService with ApiService and AuthService dependencies
        ProxyProvider2<ApiService, AuthService, MedicalRecordsService>(
          update: (context, apiService, authService, previous) =>
              MedicalRecordsService(apiService, authService),
        ),
        // Initialize DoctorService with ApiService dependency
        ProxyProvider<ApiService, DoctorService>(
          update: (context, apiService, previous) => DoctorService(apiService),
        ), // Initialize PrescriptionService with ApiService dependency
        ProxyProvider<ApiService, PrescriptionService>(
          update: (context, apiService, previous) =>
              PrescriptionService(apiService),
        ),
        // Initialize HealthRecordsService with dependencies
        ProxyProvider2<ApiService, AuthService, HealthRecordsService>(
          update: (context, apiService, authService, previous) =>
              HealthRecordsService(apiService, authService),
        ), // Initialize providers with dependencies
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) =>
              AuthProvider(Provider.of<AuthService>(context, listen: false)),
          update: (context, authService, previous) =>
              previous ?? AuthProvider(authService),
        ),
        ChangeNotifierProxyProvider4<MedicalRecordsService, AuthService,
            ConnectivityService, CacheService, HealthRecordProvider>(
          create: (context) => HealthRecordProvider(
            Provider.of<MedicalRecordsService>(context, listen: false),
            Provider.of<AuthService>(context, listen: false),
            Provider.of<ConnectivityService>(context, listen: false),
            Provider.of<CacheService>(context, listen: false),
          ),
          update: (context, medicalRecordsService, authService,
                  connectivityService, cacheService, previous) =>
              previous ??
              HealthRecordProvider(medicalRecordsService, authService,
                  connectivityService, cacheService),
        ),
        // Initialize VisitsHealthProvider with dependencies
        ChangeNotifierProxyProvider4<HealthRecordsService, AuthService,
            ConnectivityService, CacheService, VisitsHealthProvider>(
          create: (context) => VisitsHealthProvider(
            Provider.of<HealthRecordsService>(context, listen: false),
            Provider.of<AuthService>(context, listen: false),
            Provider.of<ConnectivityService>(context, listen: false),
            Provider.of<CacheService>(context, listen: false),
          ),
          update: (context, healthRecordsService, authService,
                  connectivityService, cacheService, previous) =>
              previous ??
              VisitsHealthProvider(healthRecordsService, authService,
                  connectivityService, cacheService),
        ),
        ChangeNotifierProvider(
            create: (_) => notifications.NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VitalMeasurementsProvider()),
        Provider<EmailService>(
          create: (context) => EmailService(context.read<AuthService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initialize providers after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize auth provider
      Provider.of<AuthProvider>(context, listen: false).initialize();
      // Initialize notification provider
      Provider.of<notifications.NotificationProvider>(context, listen: false)
          .initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'DPHR',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.flutterThemeMode,
      home: const SplashScreen(),
    );
  }
}
