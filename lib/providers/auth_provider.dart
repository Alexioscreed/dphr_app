import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String _error = '';

  AuthProvider(this._authService);

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

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.forgotPassword(email);
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Forgot password error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send Reset Code
  Future<bool> sendResetCode(String email) async {
    _setLoading(true);
    try {
      await _authService.sendResetCode(email);
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Send reset code error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify Reset Code
  Future<bool> verifyResetCode(String email, String code) async {
    _setLoading(true);
    try {
      await _authService.verifyResetCode(email, code);
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Verify reset code error: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset Password with Code
  Future<bool> resetPasswordWithCode(
      String email, String code, String newPassword) async {
    _setLoading(true);
    try {
      await _authService.resetPasswordWithCode(email, code, newPassword);
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Reset password with code error: $_error');
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
