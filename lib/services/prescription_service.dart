import '../models/prescription.dart';
import 'api_service.dart';

class PrescriptionService {
  final ApiService _apiService;

  PrescriptionService(this._apiService);

  Future<List<Prescription>> getAllPrescriptions() async {
    try {
      final data = await _apiService.get('prescriptions');

      if (data is List) {
        return data.map((json) => Prescription.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching prescriptions: $e');
    }
  }

  Future<List<Prescription>> getPrescriptionsByPatient(int patientId) async {
    try {
      final data = await _apiService.get('prescriptions?patientId=$patientId');

      if (data is List) {
        return data.map((json) => Prescription.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching prescriptions for patient: $e');
    }
  }

  Future<List<Prescription>> getPrescriptionsByDoctor(int doctorId) async {
    try {
      final data = await _apiService.get('prescriptions?doctorId=$doctorId');

      if (data is List) {
        return data.map((json) => Prescription.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching prescriptions for doctor: $e');
    }
  }

  Future<List<Prescription>> getPrescriptionsByStatus(String status) async {
    try {
      final data = await _apiService.get('prescriptions?status=$status');

      if (data is List) {
        return data.map((json) => Prescription.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching prescriptions by status: $e');
    }
  }

  Future<Prescription> getPrescriptionById(int id) async {
    try {
      final data = await _apiService.get('prescriptions/$id');
      return Prescription.fromMap(data);
    } catch (e) {
      throw Exception('Error fetching prescription: $e');
    }
  }

  Future<Prescription> createPrescription(Prescription prescription) async {
    try {
      final data =
          await _apiService.post('prescriptions', prescription.toMap());
      return Prescription.fromMap(data);
    } catch (e) {
      throw Exception('Error creating prescription: $e');
    }
  }

  Future<Prescription> updatePrescription(
      int id, Prescription prescription) async {
    try {
      final data =
          await _apiService.put('prescriptions/$id', prescription.toMap());
      return Prescription.fromMap(data);
    } catch (e) {
      throw Exception('Error updating prescription: $e');
    }
  }

  Future<void> deletePrescription(int id) async {
    try {
      await _apiService.delete('prescriptions/$id');
    } catch (e) {
      throw Exception('Error deleting prescription: $e');
    }
  }

  Future<Prescription> updatePrescriptionStatus(int id, String status) async {
    try {
      final data =
          await _apiService.put('prescriptions/$id/status', {'status': status});
      return Prescription.fromMap(data);
    } catch (e) {
      throw Exception('Error updating prescription status: $e');
    }
  }

  Future<List<Prescription>> getActivePrescriptions() async {
    return await getPrescriptionsByStatus('active');
  }

  Future<List<Prescription>> getCompletedPrescriptions() async {
    return await getPrescriptionsByStatus('completed');
  }

  Future<List<Prescription>> getDiscontinuedPrescriptions() async {
    return await getPrescriptionsByStatus('discontinued');
  }

  Future<List<Prescription>> searchPrescriptions(String query) async {
    try {
      final data = await _apiService.get('prescriptions/search?q=$query');

      if (data is List) {
        return data.map((json) => Prescription.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error searching prescriptions: $e');
    }
  }

  Future<List<Prescription>> getPrescriptionsByMedication(
      int medicationId) async {
    try {
      final data =
          await _apiService.get('prescriptions?medicationId=$medicationId');

      if (data is List) {
        return data.map((json) => Prescription.fromMap(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching prescriptions for medication: $e');
    }
  }
}
