class Doctor {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? specialization;
  final String? licenseNumber;
  final String? department;

  Doctor({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.specialization,
    this.licenseNumber,
    this.department,
  });

  // Convert to Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'department': department,
    };
  }

  // Create from Map for API responses
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id']?.toInt(),
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      specialization: map['specialization'],
      licenseNumber: map['licenseNumber'],
      department: map['department'],
    );
  }

  // Convert to JSON string
  String toJson() => toMap().toString();

  // Create from JSON string
  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor.fromMap(json);

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Get display name with specialization
  String get displayName {
    if (specialization != null && specialization!.isNotEmpty) {
      return '$fullName ($specialization)';
    }
    return fullName;
  }

  // Create a copy with updated fields
  Doctor copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? specialization,
    String? licenseNumber,
    String? department,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      department: department ?? this.department,
    );
  }

  @override
  String toString() {
    return 'Doctor{id: $id, fullName: $fullName, specialization: $specialization, department: $department}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
