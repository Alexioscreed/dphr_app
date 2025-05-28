import '../models/doctor.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService;

  DoctorService(this._apiService);

  Future<List<Doctor>> getAllDoctors() async {
    try {
      final data = await _apiService.get('doctors');

      if (data is List) {
        return data.map((json) => Doctor.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }

  Future<Doctor> getDoctorById(int id) async {
    try {
      final data = await _apiService.get('doctors/$id');
      return Doctor.fromMap(data);
    } catch (e) {
      throw Exception('Error fetching doctor: $e');
    }
  }

  Future<Doctor> createDoctor(Doctor doctor) async {
    try {
      final data = await _apiService.post('doctors', doctor.toMap());
      return Doctor.fromMap(data);
    } catch (e) {
      throw Exception('Error creating doctor: $e');
    }
  }

  Future<Doctor> updateDoctor(int id, Doctor doctor) async {
    try {
      final data = await _apiService.put('doctors/$id', doctor.toMap());
      return Doctor.fromMap(data);
    } catch (e) {
      throw Exception('Error updating doctor: $e');
    }
  }

  Future<void> deleteDoctor(int id) async {
    try {
      await _apiService.delete('doctors/$id');
    } catch (e) {
      throw Exception('Error deleting doctor: $e');
    }
  }

  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    try {
      final data =
          await _apiService.get('doctors?specialization=$specialization');

      if (data is List) {
        return data.map((json) => Doctor.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching doctors by specialization: $e');
    }
  }

  Future<List<Doctor>> getDoctorsByDepartment(String department) async {
    try {
      final data = await _apiService.get('doctors?department=$department');

      if (data is List) {
        return data.map((json) => Doctor.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching doctors by department: $e');
    }
  }

  Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final data = await _apiService.get('doctors/search?q=$query');

      if (data is List) {
        return data.map((json) => Doctor.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error searching doctors: $e');
    }
  }
}
