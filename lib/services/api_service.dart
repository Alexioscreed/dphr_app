import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';
import '../utils/constants.dart';
import '../utils/api_exception.dart';

class ApiService {
  final String baseUrl;
  final String username;
  final String password;
  final String hfrCode;

  ApiService({
    required this.baseUrl,
    required this.username,
    required this.password,
    required this.hfrCode,
  });

  // Basic authentication header
  String get _basicAuth => 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': _basicAuth,
    'Accept': 'application/json',
  };

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw ApiException('Bad request: ${response.body}', response.statusCode);
      case 401:
        throw ApiException('Unauthorized: Invalid credentials', response.statusCode);
      case 403:
        throw ApiException('Forbidden: Insufficient permissions', response.statusCode);
      case 404:
        throw ApiException('Not found: The requested resource does not exist', response.statusCode);
      case 500:
        throw ApiException('Server error: Please try again later', response.statusCode);
      default:
        throw ApiException('Unknown error: ${response.statusCode}', response.statusCode);
    }
  }

  // Client Registry (CR) API Endpoints

  // Register a client
  Future<ClientRegistrationResponse> registerClient(ClientRegistration clientData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/hduApi/cr/clients'),
      headers: _headers,
      body: json.encode(clientData.toJson()),
    );

    final data = _handleResponse(response);
    return ClientRegistrationResponse.fromJson(data);
  }

  // Get client by identifier
  Future<ClientResponse> getClientByIdentifier(String id, String idType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/hduApi/cr/clients?id=$id&idType=$idType&hfrCode=$hfrCode'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return ClientResponse.fromJson(data);
  }

  // Update client information
  Future<ClientRegistrationResponse> updateClient(String clientId, ClientRegistration clientData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/hduApi/cr/clients/$clientId'),
      headers: _headers,
      body: json.encode(clientData.toJson()),
    );

    final data = _handleResponse(response);
    return ClientRegistrationResponse.fromJson(data);
  }

  // Shared Health Record (SHR) API Endpoints

  // Get shared health records
  Future<SharedRecordsResponse> getSharedRecords(String id, String idType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/hduApi/shr/sharedRecords?id=$id&idType=$idType&hfrCode=$hfrCode'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return SharedRecordsResponse.fromJson(data);
  }

  // Submit shared health record
  Future<SubmitRecordResponse> submitSharedRecord(HealthRecordSubmission recordData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/hduApi/shr/sharedRecords'),
      headers: _headers,
      body: json.encode(recordData.toJson()),
    );

    final data = _handleResponse(response);
    return SubmitRecordResponse.fromJson(data);
  }

  // Data Templates API Endpoints

  // Get all data templates
  Future<DataTemplatesResponse> getDataTemplates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/hduApi/dataTemplates'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return DataTemplatesResponse.fromJson(data);
  }

  // Get specific data template
  Future<DataTemplateResponse> getDataTemplate(String templateId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/hduApi/dataTemplates/$templateId'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return DataTemplateResponse.fromJson(data);
  }

  // Submit data using template
  Future<SubmitRecordResponse> submitDataWithTemplate(String templateId, HealthRecordSubmission recordData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/hduApi/dataTemplates/$templateId/data'),
      headers: _headers,
      body: json.encode(recordData.toJson()),
    );

    final data = _handleResponse(response);
    return SubmitRecordResponse.fromJson(data);
  }

  // Standard Codes API Endpoints

  // Get ICD-10 codes
  Future<CodeSystemResponse> getIcdCodes(String query, {int page = 0, int pageSize = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/hduApi/codeSystems/icd/codes?q=$query&page=$page&pageSize=$pageSize'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return CodeSystemResponse.fromJson(data);
  }

  // Get LOINC codes
  Future<CodeSystemResponse> getLoincCodes(String query, {int page = 0, int pageSize = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/hduApi/codeSystems/loinc?q=$query&page=$page&pageSize=$pageSize'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return CodeSystemResponse.fromJson(data);
  }

  // Referral API Endpoints

  // Submit referral
  Future<ReferralResponse> submitReferral(ReferralSubmission referralData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/hduApi/referrals'),
      headers: _headers,
      body: json.encode(referralData.toJson()),
    );

    final data = _handleResponse(response);
    return ReferralResponse.fromJson(data);
  }

  // Get referrals for a client
  Future<ReferralsResponse> getClientReferrals(String id, String idType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/hduApi/referrals?id=$id&idType=$idType&hfrCode=$hfrCode'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return ReferralsResponse.fromJson(data);
  }

  // Update referral status
  Future<ReferralResponse> updateReferralStatus(String referralId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/hduApi/referrals/$referralId/status'),
      headers: _headers,
      body: json.encode({'status': status}),
    );

    final data = _handleResponse(response);
    return ReferralResponse.fromJson(data);
  }
}

