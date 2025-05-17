import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shared_record.dart';

class ApiService {
  final String baseUrl;
  final String username;
  final String password;
  final String hfrCode;
  String? _token;

  ApiService({
    required this.baseUrl,
    required this.username,
    required this.password,
    required this.hfrCode,
  });

  // Get authentication token
  Future<String> getToken() async {
    if (_token != null) {
      return _token!;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return _token!;
      } else {
        throw Exception('Failed to get token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get token: $e');
    }
  }

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'HFR-Code': hfrCode,
    };
  }

  // Register a client
  Future<Map<String, dynamic>> registerClient(Map<String, dynamic> clientData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/clients/register'),
        headers: headers,
        body: jsonEncode(clientData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register client: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to register client: $e');
    }
  }

  // Fetch shared records
  Future<List<SharedRecord>> fetchSharedRecords() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/shared-records'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => SharedRecord.fromMap(item)).toList();
      } else {
        throw Exception('Failed to fetch shared records: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch shared records: $e');
    }
  }

  // Get shared record by ID
  Future<SharedRecord> getSharedRecordById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/shared-records/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SharedRecord.fromMap(data);
      } else {
        throw Exception('Failed to get shared record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get shared record: $e');
    }
  }

  // Share health record
  Future<Map<String, dynamic>> shareHealthRecord(Map<String, dynamic> shareData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/share-record'),
        headers: headers,
        body: jsonEncode(shareData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to share record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to share record: $e');
    }
  }
}
