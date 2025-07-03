class ProfileInformation {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final String? bloodType;
  final String? allergies;
  final String? medicalConditions;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileInformation({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.bloodType,
    this.allergies,
    this.medicalConditions,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'blood_type': bloodType,
      'allergies': allergies,
      'medical_conditions': medicalConditions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map for database retrieval
  factory ProfileInformation.fromMap(Map<String, dynamic> map) {
    return ProfileInformation(
      id: map['id'],
      userId: map['user_id'],
      fullName: map['full_name'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'])
          : null,
      gender: map['gender'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zip_code'],
      country: map['country'],
      bloodType: map['blood_type'],
      allergies: map['allergies'],
      medicalConditions: map['medical_conditions'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  ProfileInformation copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? bloodType,
    String? allergies,
    String? medicalConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileInformation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
