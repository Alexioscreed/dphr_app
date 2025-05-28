class User {
  final String id;
  final String name;
  final String email;
  final String mrn;
  final String? patientUuid; // OpenMRS-style Patient UUID
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final List<String>? allergies;
  final List<String>? medications;
  final List<String>? conditions;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mrn,
    this.patientUuid,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.allergies,
    this.medications,
    this.conditions,
  });
  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mrn': mrn,
      'patientUuid': patientUuid,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'conditions': conditions,
    };
  }
  // Create from Map for database retrieval
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mrn: map['mrn'] ?? '',
      patientUuid: map['patientUuid'],
      phone: map['phone'],
      address: map['address'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      bloodType: map['bloodType'],
      allergies: map['allergies'] != null ? List<String>.from(map['allergies']) : null,
      medications: map['medications'] != null ? List<String>.from(map['medications']) : null,
      conditions: map['conditions'] != null ? List<String>.from(map['conditions']) : null,
    );
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User.fromMap(json);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }
}
