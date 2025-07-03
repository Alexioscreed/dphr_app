import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/profile_information.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService, AuthService authService);

  /// Get user profile information
  Future<ProfileInformation?> getProfile() async {
    try {
      debugPrint('Fetching user profile information');

      final response = await _apiService.get('profile/me');

      if (response != null && response is Map<String, dynamic>) {
        return ProfileInformation.fromMap(response);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Update user profile information
  Future<bool> updateProfile(ProfileInformation profile) async {
    try {
      debugPrint('Updating user profile information');

      final response = await _apiService.put('profile/me', profile.toMap());

      return response != null;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Create user profile information
  Future<ProfileInformation?> createProfile(ProfileInformation profile) async {
    try {
      debugPrint('Creating user profile information');

      final response = await _apiService.post('profile', profile.toMap());

      if (response != null && response is Map<String, dynamic>) {
        return ProfileInformation.fromMap(response);
      }

      return null;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Get patient demographics from health records
  Future<Map<String, dynamic>?> getPatientDemographics() async {
    try {
      debugPrint('Fetching patient demographics');

      final response = await _apiService.get('health-records/demographics');

      if (response != null && response is Map<String, dynamic>) {
        return response;
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching patient demographics: $e');
      throw Exception('Failed to fetch patient demographics: $e');
    }
  }
}
