import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8080/api';
  final AuthService _authService;

  ApiService(this._authService);

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _authService.getAuthHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: ${e.toString()}');
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: ${e.toString()}');
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: ${e.toString()}');
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _authService.getAuthHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: ${e.toString()}');
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Handle unauthorized - clear token
      _authService.logout();
      throw Exception('Session expired. Please login again.');
    } else {
      // Handle other errors
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Request failed with status: ${response.statusCode}');
      } catch (e) {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    }
  }
}
