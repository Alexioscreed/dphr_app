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
        final response = await client
            .post(
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
            )
            .timeout(Duration(seconds: AppConfig.connectionTimeout));

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('Registration successful');
          return;
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Registration failed with status: ${response.statusCode}';
          } catch (_) {
            errorMsg =
                'Registration failed with status: ${response.statusCode}';
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
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
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
        final response = await client
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'email': email,
                'password': password,
              }),
            )
            .timeout(Duration(seconds: AppConfig.connectionTimeout));
        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Raw response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          debugPrint('Parsed response data: $data');
          debugPrint('Token: ${data['token']}');
          debugPrint('Patient UUID: ${data['patientUuid']}');

          _token = data['token'];

          // Save token to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenKey,
              _token!); // Create a basic user object with the response data
          _currentUser = User(
            id: data['id']?.toString() ?? '1',
            name: data['name'] ?? 'User',
            email: email,
            mrn: data['mrn'] ??
                '', // Use actual MRN from backend instead of hardcoded fallback
            patientUuid:
                data['patientUuid'], // Store the patient UUID from backend
          );

          debugPrint('Created user: ${_currentUser?.toJson()}');

          // Save user data to SharedPreferences
          await prefs.setString(userKey, jsonEncode(_currentUser!.toJson()));
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Login failed with status: ${response.statusCode}';
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
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        throw Exception('Login failed: $e');
      }
    }
  }

  // Forgot Password
  Future<String> forgotPassword(String email) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/forgot-password';
      debugPrint('Attempting forgot password at: $url');

      final client = http.Client();

      try {
        final response = await client
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'email': email,
              }),
            )
            .timeout(Duration(seconds: AppConfig.connectionTimeout));

        debugPrint('Forgot password response status: ${response.statusCode}');
        debugPrint('Forgot password response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response.body; // Return the success message
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Failed to send reset link with status: ${response.statusCode}';
          } catch (_) {
            errorMsg =
                'Failed to send reset link with status: ${response.statusCode}';
          }
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Forgot password exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        throw Exception('Failed to send reset link: $e');
      }
    }
  }

  // Send Reset Code
  Future<String> sendResetCode(String email) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/send-reset-code';
      debugPrint('Attempting to send reset code at: $url');

      final client = http.Client();

      try {
        final response = await client
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'email': email,
              }),
            )
            .timeout(Duration(seconds: AppConfig.connectionTimeout));

        debugPrint('Send reset code response status: ${response.statusCode}');
        debugPrint('Send reset code response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response.body; // Return the success message
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Failed to send reset code with status: ${response.statusCode}';
          } catch (_) {
            errorMsg =
                'Failed to send reset code with status: ${response.statusCode}';
          }
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Send reset code exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        throw Exception('Failed to send reset code: $e');
      }
    }
  }

  // Verify Reset Code
  Future<String> verifyResetCode(String email, String code) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/verify-reset-code';
      debugPrint('Attempting to verify reset code at: $url');

      final client = http.Client();

      try {
        final response = await client
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'email': email,
                'code': code,
              }),
            )
            .timeout(Duration(seconds: AppConfig.connectionTimeout));

        debugPrint('Verify reset code response status: ${response.statusCode}');
        debugPrint('Verify reset code response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response.body; // Return the success message
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Failed to verify reset code with status: ${response.statusCode}';
          } catch (_) {
            errorMsg =
                'Failed to verify reset code with status: ${response.statusCode}';
          }
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Verify reset code exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        throw Exception('Failed to verify reset code: $e');
      }
    }
  }

  // Reset Password with Code
  Future<String> resetPasswordWithCode(
      String email, String code, String newPassword) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/reset-password-with-code';
      debugPrint('Attempting to reset password with code at: $url');

      final client = http.Client();

      try {
        final response = await client
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'email': email,
                'code': code,
                'newPassword': newPassword,
              }),
            )
            .timeout(Duration(seconds: AppConfig.connectionTimeout));

        debugPrint(
            'Reset password with code response status: ${response.statusCode}');
        debugPrint('Reset password with code response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response.body; // Return the success message
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Failed to reset password with status: ${response.statusCode}';
          } catch (_) {
            errorMsg =
                'Failed to reset password with status: ${response.statusCode}';
          }
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Reset password with code exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        throw Exception('Failed to reset password with code: $e');
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

  // Send OTP for registration
  Future<bool> sendRegistrationOtp(
      String name, String email, String phoneNumber, String password) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/send-otp';
      debugPrint('Attempting to send OTP at: $url');
      debugPrint('Request data: name=$name, email=$email, phone=$phoneNumber');

      final client = http.Client();

      try {
        final response = await client
            .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            'password': password,
          }),
        )
            .timeout(
          Duration(seconds: AppConfig.otpTimeout),
          onTimeout: () {
            debugPrint(
                'Send OTP request timed out after ${AppConfig.otpTimeout} seconds');
            throw TimeoutException(
                'Request timed out', Duration(seconds: AppConfig.otpTimeout));
          },
        );

        debugPrint('Send OTP response status: ${response.statusCode}');
        debugPrint('Send OTP response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            debugPrint('OTP sent successfully - navigating to OTP screen');
            return true;
          } else {
            final errorMessage =
                responseData['message'] ?? 'Failed to send OTP';
            debugPrint('OTP send failed: $errorMessage');
            throw Exception(errorMessage);
          }
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Failed to send OTP with status: ${response.statusCode}';
          } catch (_) {
            errorMsg = 'Failed to send OTP with status: ${response.statusCode}';
          }
          debugPrint(
              'OTP send failed with status ${response.statusCode}: $errorMsg');
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Send OTP exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception(
            'Connection timed out after ${AppConfig.otpTimeout} seconds. Please try again later.');
      } else {
        rethrow;
      }
    }
  }

  // Verify OTP and complete registration
  Future<void> verifyOtpAndRegister(String name, String email,
      String phoneNumber, String password, String otp) async {
    try {
      final url = '${AppConfig.baseApiUrl}/auth/verify-otp-register';
      debugPrint('Attempting to verify OTP and register at: $url');

      final client = http.Client();

      try {
        final response = await client
            .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            'password': password,
            'otp': otp,
          }),
        )
            .timeout(
          Duration(seconds: AppConfig.otpTimeout),
          onTimeout: () {
            debugPrint(
                'Verify OTP request timed out after ${AppConfig.otpTimeout} seconds');
            throw TimeoutException(
                'Request timed out', Duration(seconds: AppConfig.otpTimeout));
          },
        );

        debugPrint('Verify OTP response status: ${response.statusCode}');
        debugPrint('Verify OTP response body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            final authResponse = responseData['authResponse'];

            // Save token and user data
            await _saveAuthData(
              authResponse['token'],
              User(
                id: authResponse[
                    'email'], // Use email as temporary ID since backend doesn't return user ID
                email: authResponse['email'],
                name: authResponse['name'],
                mrn: authResponse['mrn'] ?? '',
                patientUuid: authResponse['patientUuid'],
              ),
            );

            debugPrint('Registration and login successful');
            return;
          } else {
            throw Exception(
                responseData['message'] ?? 'Failed to verify OTP and register');
          }
        } else {
          String errorMsg;
          try {
            final error = jsonDecode(response.body);
            errorMsg = error['message'] ??
                'Failed to verify OTP with status: ${response.statusCode}';
          } catch (_) {
            errorMsg =
                'Failed to verify OTP with status: ${response.statusCode}';
          }
          throw Exception(errorMsg);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Verify OTP exception: $e');

      // Provide more specific error messages
      if (e is SocketException) {
        throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.');
      } else if (e is http.ClientException) {
        throw Exception('Network error: ${e.message}. Please try again later.');
      } else if (e is TimeoutException) {
        throw Exception('Connection timed out. Please try again later.');
      } else {
        rethrow;
      }
    }
  }

  // Save token and user data
  Future<void> _saveAuthData(String token, User user) async {
    _token = token;
    _currentUser = user;

    // Save token and user data to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }
}
