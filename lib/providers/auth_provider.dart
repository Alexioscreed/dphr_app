import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _error = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.isAuthenticated;
  User? get currentUser => _authService.currentUser;
  String get error => _error;
  String? get token => _authService.token;

  // Initialize the auth provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      _error = '';
    } catch (e) {
      _error = e.toString();
      debugPrint('Error initializing auth provider: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // This method is needed for backward compatibility
  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      _error = '';
      return _authService.isAuthenticated;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error checking auth status: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register a new user
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.register(name, email, password);
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Registration error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.login(email, password);
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Login error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _error = '';
    } catch (e) {
      _error = e.toString();
      debugPrint('Logout error: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get auth headers for API requests
  Map<String, String> getAuthHeaders() {
    return _authService.getAuthHeaders();
  }
}
