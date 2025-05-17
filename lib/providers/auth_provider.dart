import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _error = '';
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null && token.isNotEmpty) {
        // In a real app, you would validate the token with the server
        final userData = prefs.getString(_userKey);
        if (userData != null) {
          // Parse user data and set user
          _user = User(
            id: '1',
            name: 'John Doe',
            email: 'john.doe@example.com',
            mrn: '12345678',
          );
          _isAuthenticated = true;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would validate credentials with the server
      if (email == 'test@example.com' && password == 'password') {
        _user = User(
          id: '1',
          name: 'John Doe',
          email: email,
          mrn: '12345678',
        );

        _isAuthenticated = true;

        // Save auth token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'sample_token');
        await prefs.setString(_userKey, '{"id":"1","name":"John Doe","email":"$email","mrn":"12345678"}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register user
  Future<bool> register(String name, String email, String password, String mrn) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would register the user with the server
      _user = User(
        id: '1',
        name: name,
        email: email,
        mrn: mrn,
      );

      _isAuthenticated = true;

      // Save auth token and user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'sample_token');
      await prefs.setString(_userKey, '{"id":"1","name":"$name","email":"$email","mrn":"$mrn"}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear user data and token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);

      _user = null;
      _isAuthenticated = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
