class Treatment {
  final int? id;
  final int encounterId;
  final String treatmentName;
  final String treatmentType;
  final String description;
  final String provider;
  final DateTime? startDate;
  final DateTime? endDate;
  final String frequency;
  final String duration;
  final String location;
  final String status;
  final String outcome;
  final String notes;
  final String instructions;

  Treatment({
    this.id,
    required this.encounterId,
    required this.treatmentName,
    required this.treatmentType,
    required this.description,
    required this.provider,
    this.startDate,
    this.endDate,
    required this.frequency,
    required this.duration,
    required this.location,
    required this.status,
    required this.outcome,
    required this.notes,
    required this.instructions,
  });

  factory Treatment.fromMap(Map<String, dynamic> map) {
    return Treatment(
      id: map['id']?.toInt(),
      encounterId: map['encounterId']?.toInt() ?? 0,
      treatmentName: map['treatmentName'] ?? '',
      treatmentType: map['treatmentType'] ?? '',
      description: map['description'] ?? '',
      provider: map['provider'] ?? '',
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      location: map['location'] ?? '',
      status: map['status'] ?? '',
      outcome: map['outcome'] ?? '',
      notes: map['notes'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encounterId': encounterId,
      'treatmentName': treatmentName,
      'treatmentType': treatmentType,
      'description': description,
      'provider': provider,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'frequency': frequency,
      'duration': duration,
      'location': location,
      'status': status,
      'outcome': outcome,
      'notes': notes,
      'instructions': instructions,
    };
  }
}
