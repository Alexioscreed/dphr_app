import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/api_models.dart';
import '../utils/constants.dart';
import '../utils/api_exception.dart';

class ApiProvider with ChangeNotifier {
  late ApiService _apiService;
  bool _isLoading = false;
  String _error = '';

  // Client Registry data
  ClientResponse? _clientData;

  // Shared Health Records data
  SharedRecordsResponse? _sharedRecords;

  // Data Templates data
  DataTemplatesResponse? _dataTemplates;
  DataTemplateResponse? _dataTemplate;

  // Code Systems data
  CodeSystemResponse? _icdCodes;
  CodeSystemResponse? _loincCodes;

  // Referrals data
  ReferralsResponse? _referrals;

  ApiProvider() {
    _apiService = ApiService(
      baseUrl: ApiConstants.baseUrl,
      username: ApiConstants.apiUsername,
      password: ApiConstants.apiPassword,
      hfrCode: ApiConstants.hfrCode,
    );
  }

  bool get isLoading => _isLoading;
  String get error => _error;
  ClientResponse? get clientData => _clientData;
  SharedRecordsResponse? get sharedRecords => _sharedRecords;
  DataTemplatesResponse? get dataTemplates => _dataTemplates;
  DataTemplateResponse? get dataTemplate => _dataTemplate;
  CodeSystemResponse? get icdCodes => _icdCodes;
  CodeSystemResponse? get loincCodes => _loincCodes;
  ReferralsResponse? get referrals => _referrals;

  // Reset error
  void resetError() {
    _error = '';
    notifyListeners();
  }

  // Client Registry Methods without caching

  Future<ClientRegistrationResponse?> registerClient(ClientRegistration clientData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _apiService.registerClient(clientData);
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchClientByIdentifier(String id, String idType, {bool forceRefresh = false}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Fetch from API
      _clientData = await _apiService.getClientByIdentifier(id, idType);

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ClientRegistrationResponse?> updateClient(String clientId, ClientRegistration clientData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _apiService.updateClient(clientId, clientData);
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Shared Health Records Methods without caching

  Future<void> fetchSharedRecords(String id, String idType, {bool forceRefresh = false}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Fetch from API
      _sharedRecords = await _apiService.getSharedRecords(id, idType);

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SubmitRecordResponse?> submitSharedRecord(HealthRecordSubmission recordData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _apiService.submitSharedRecord(recordData);
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Data Templates Methods

  Future<void> fetchDataTemplates() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _dataTemplates = await _apiService.getDataTemplates();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDataTemplate(String templateId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _dataTemplate = await _apiService.getDataTemplate(templateId);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SubmitRecordResponse?> submitDataWithTemplate(String templateId, HealthRecordSubmission recordData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _apiService.submitDataWithTemplate(templateId, recordData);
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Code Systems Methods

  Future<void> fetchIcdCodes(String query, {int page = 0, int pageSize = 10}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _icdCodes = await _apiService.getIcdCodes(query, page: page, pageSize: pageSize);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLoincCodes(String query, {int page = 0, int pageSize = 10}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _loincCodes = await _apiService.getLoincCodes(query, page: page, pageSize: pageSize);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Referrals Methods

  Future<ReferralResponse?> submitReferral(ReferralSubmission referralData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _apiService.submitReferral(referralData);
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchClientReferrals(String id, String idType) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _referrals = await _apiService.getClientReferrals(id, idType);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReferralResponse?> updateReferralStatus(String referralId, String status) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _apiService.updateReferralStatus(referralId, status);
      _isLoading = false;
      notifyListeners();
      return result;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}

