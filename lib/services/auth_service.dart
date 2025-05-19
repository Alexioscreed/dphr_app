import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class AuthService {
  // Constants for SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Current user and token
  User? _currentUser;
  String? _token;

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // Initialize - load token and user from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(tokenKey);

      final userData = prefs.getString(userKey);
      if (userData != null) {
        try {
          _currentUser = User.fromJson(jsonDecode(userData));
        } catch (e) {
          // Invalid user data, clear it
          await prefs.remove(userKey);
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
    }
  }

  // Register a new user
  Future<void> register(String name, String email, String password) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/signup';
      debugPrint('Attempting to register at: $url');

      final client = http.Client();

      try {
        final response = await client.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        ).timeout(Duration(seconds: AppConfig.connectionTimeout));

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('Registration successful');
          return;
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ?? 'Registration failed with status: ${response.statusCode}';
          } catch (_) {
            errorMsg = 'Registration failed with status: ${response.statusCode}';
          }
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Registration exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception('Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        throw Exception('Registration failed: $e');
      }
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/login';
      debugPrint('Attempting to login at: $url');

      final client = http.Client();

      try {
        final response = await client.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ).timeout(Duration(seconds: AppConfig.connectionTimeout));

        debugPrint('Response status: ${response.statusCode}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          _token = data['token'];

          // Save token to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenKey, _token!);

          // Create a basic user object with the email
          _currentUser = User(
            id: '1',
            name: data['name'] ?? 'User',
            email: email,
            mrn: data['mrn'] ?? 'MRN123',
          );

          // Save user data to SharedPreferences
          await prefs.setString(userKey, jsonEncode(_currentUser!.toJson()));
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ?? 'Login failed with status: ${response.statusCode}';
          } catch (_) {
            errorMsg = 'Login failed with status: ${response.statusCode}';
          }
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Login exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception('Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        throw Exception('Login failed: $e');
      }
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _currentUser = null;

    // Clear token and user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Get auth headers for API requests
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}
