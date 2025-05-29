import 'dart:convert';

class Patient {
  final int? id;
  final String? patientUuid;
  final String? mrn;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? allergies;

  Patient({
    this.id,
    this.patientUuid,
    this.mrn,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.allergies,
  });

  // Convert to Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientUuid': patientUuid,
      'mrn': mrn,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth
          ?.toIso8601String()
          .split('T')[0], // Format as YYYY-MM-DD      'gender': gender,
      'bloodType': bloodType,
      'address': address,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'allergies': allergies,
    };
  }

  // Create from Map for API responses
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id']?.toInt(),
      patientUuid: map['patientUuid'],
      mrn: map['mrn'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      gender: map['gender'],
      bloodType: map['bloodType'],
      address: map['address'],
      emergencyContactName: map['emergencyContactName'],
      emergencyContactPhone: map['emergencyContactPhone'],
      allergies: map['allergies'],
    );
  }
  // Convert to JSON string
  String toJson() => jsonEncode(toMap());

  // Create from JSON string
  factory Patient.fromJson(Map<String, dynamic> json) => Patient.fromMap(json);

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Create a copy with updated fields
  Patient copyWith({
    int? id,
    String? patientUuid,
    String? mrn,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? allergies,
  }) {
    return Patient(
      id: id ?? this.id,
      patientUuid: patientUuid ?? this.patientUuid,
      mrn: mrn ?? this.mrn,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      allergies: allergies ?? this.allergies,
    );
  }
}
