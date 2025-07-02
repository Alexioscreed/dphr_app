import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_screen.dart';
import 'home/dashboard_screen.dart';
import 'landing_page.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Set up animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();

    // Check auth status and navigate
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if this is the first launch
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('hasLaunched') ?? false;

    // If it's the first launch, navigate to the landing page
    if (!hasLaunched) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
      return;
    }

    // Otherwise, continue with normal auth flow
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // Navigate based on authentication status
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3), // Updated to blue
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App name with fade transition
            FadeTransition(
              opacity: _animation,
              child: const Column(
                children: [
                  Text(
                    'DPHR',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3), // Updated to blue
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Digital Personal Health Record',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
