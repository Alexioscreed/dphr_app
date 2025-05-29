import 'dart:convert';
import 'lab_result.dart';
import 'medication.dart';
import 'diagnosis_detail.dart';
import 'treatment.dart';
import 'doctor.dart';

class Encounter {
  final dynamic id; // Can be int (from database) or String (UUID from file)
  final int patientId;
  final int? doctorId;
  final Doctor? doctor;
  final String encounterType;
  final DateTime encounterDateTime;
  final String location;
  final String provider;
  final String notes;
  final String diagnosis;
  final String? chiefComplaint;
  final String status;
  final List<Observation> observations;
  final List<VitalSign> vitalSigns;
  final List<LabResult> labResults;
  final List<Medication> medications;
  final List<DiagnosisDetail> diagnoses;
  final List<Treatment> treatments;
  Encounter({
    this.id,
    required this.patientId,
    this.doctorId,
    this.doctor,
    required this.encounterType,
    required this.encounterDateTime,
    required this.location,
    required this.provider,
    required this.notes,
    required this.diagnosis,
    this.chiefComplaint,
    required this.status,
    this.observations = const [],
    this.vitalSigns = const [],
    this.labResults = const [],
    this.medications = const [],
    this.diagnoses = const [],
    this.treatments = const [],
  });
  // Convert to Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'encounterType': encounterType,
      'encounterDateTime': encounterDateTime.toIso8601String(),
      'location': location,
      'provider': provider,
      'notes': notes,
      'diagnosis': diagnosis,
      'chiefComplaint': chiefComplaint,
      'status': status,
    };
  }

  // Create from Map for API responses
  factory Encounter.fromMap(Map<String, dynamic> map) {
    return Encounter(
      id: map['id'], // Keep as-is, can be int or string
      patientId: map['patientId']?.toInt() ?? 0,
      encounterType: map['encounterType'] ?? '',
      encounterDateTime: DateTime.parse(map['encounterDateTime']),
      location: map['location'] ?? '',
      provider: map['provider'] ?? '',
      notes: map['notes'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      status: map['status'] ?? '',
      observations: (map['observations'] as List<dynamic>?)
              ?.map((x) => Observation.fromMap(x))
              .toList() ??
          [],
      vitalSigns: (map['vitalSigns'] as List<dynamic>?)
              ?.map((x) => VitalSign.fromMap(x))
              .toList() ??
          [],
      labResults: (map['labResults'] as List<dynamic>?)
              ?.map((x) => LabResult.fromMap(x))
              .toList() ??
          [],
      medications: (map['medications'] as List<dynamic>?)
              ?.map((x) => Medication.fromMap(x))
              .toList() ??
          [],
      diagnoses: (map['diagnoses'] as List<dynamic>?)
              ?.map((x) => DiagnosisDetail.fromMap(x))
              .toList() ??
          [],
      treatments: (map['treatments'] as List<dynamic>?)
              ?.map((x) => Treatment.fromMap(x))
              .toList() ??
          [],
    );
  }
  // Convert to JSON string
  String toJson() => jsonEncode(toMap());

  // Create from JSON string
  factory Encounter.fromJson(Map<String, dynamic> json) =>
      Encounter.fromMap(json);
  // Create a copy with updated fields
  Encounter copyWith({
    int? id,
    int? patientId,
    String? encounterType,
    DateTime? encounterDateTime,
    String? location,
    String? provider,
    String? notes,
    String? diagnosis,
    String? status,
    List<Observation>? observations,
    List<VitalSign>? vitalSigns,
    List<LabResult>? labResults,
    List<Medication>? medications,
    List<DiagnosisDetail>? diagnoses,
    List<Treatment>? treatments,
  }) {
    return Encounter(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      encounterType: encounterType ?? this.encounterType,
      encounterDateTime: encounterDateTime ?? this.encounterDateTime,
      location: location ?? this.location,
      provider: provider ?? this.provider,
      notes: notes ?? this.notes,
      diagnosis: diagnosis ?? this.diagnosis,
      status: status ?? this.status,
      observations: observations ?? this.observations,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      labResults: labResults ?? this.labResults,
      medications: medications ?? this.medications,
      diagnoses: diagnoses ?? this.diagnoses,
      treatments: treatments ?? this.treatments,
    );
  }
}

class Observation {
  final int? id;
  final int? encounterId;
  final String type;
  final String value;
  final DateTime recordedAt;
  final String? notes;

  Observation({
    this.id,
    this.encounterId,
    required this.type,
    required this.value,
    required this.recordedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encounterId': encounterId,
      'type': type,
      'value': value,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      id: map['id']?.toInt(),
      encounterId: map['encounterId']?.toInt(),
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      recordedAt: DateTime.parse(map['recordedAt']),
      notes: map['notes'],
    );
  }
}

class VitalSign {
  final int? id;
  final int? encounterId;
  final int patientId;
  final String type;
  final String value;
  final DateTime recordedAt;
  final String? notes;

  VitalSign({
    this.id,
    this.encounterId,
    required this.patientId,
    required this.type,
    required this.value,
    required this.recordedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encounterId': encounterId,
      'patientId': patientId,
      'type': type,
      'value': value,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory VitalSign.fromMap(Map<String, dynamic> map) {
    return VitalSign(
      id: map['id']?.toInt(),
      encounterId: map['encounterId']?.toInt(),
      patientId: map['patientId']?.toInt() ?? 0,
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      recordedAt: DateTime.parse(map['recordedAt']),
      notes: map['notes'],
    );
  }
}
