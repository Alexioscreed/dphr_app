class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String reason;
  final String location;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String notes;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.reason,
    required this.location,
    required this.status,
    this.notes = '',
  });

  // Create a copy with modified fields
  Appointment copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    DateTime? dateTime,
    String? reason,
    String? location,
    String? status,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      dateTime: dateTime ?? this.dateTime,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': dateTime.toIso8601String(),
      'reason': reason,
      'location': location,
      'status': status,
      'notes': notes,
    };
  }

  // Create from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorName: json['doctorName'],
      specialty: json['specialty'],
      dateTime: DateTime.parse(json['dateTime']),
      reason: json['reason'],
      location: json['location'],
      status: json['status'],
      notes: json['notes'] ?? '',
    );
  }
}

