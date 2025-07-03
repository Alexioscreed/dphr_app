import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/profile_information.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService;

  ProfileInformation? _profile;
  Map<String, dynamic>? _patientDemographics;

  bool _isLoading = false;
  String _error = '';

  ProfileProvider(this._profileService);

  // Getters
  ProfileInformation? get profile => _profile;
  Map<String, dynamic>? get patientDemographics => _patientDemographics;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Reset error state
  void resetError() {
    _error = '';
    notifyListeners();
  }

  /// Fetch user profile
  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _profile = await _profileService.getProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(ProfileInformation profile) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final success = await _profileService.updateProfile(profile);
      if (success) {
        _profile = profile;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create user profile
  Future<bool> createProfile(ProfileInformation profile) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final createdProfile = await _profileService.createProfile(profile);
      if (createdProfile != null) {
        _profile = createdProfile;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch patient demographics
  Future<void> fetchPatientDemographics() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _patientDemographics = await _profileService.getPatientDemographics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
