class Prescription {
  final int? id;
  final int encounterId;
  final int medicationId;
  final int patientId;
  final String dosage;
  final String frequency;
  final String? duration;
  final String? instructions;
  final DateTime? prescribedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? quantity;
  final int? refills;
  final String? status;

  Prescription({
    this.id,
    required this.encounterId,
    required this.medicationId,
    required this.patientId,
    required this.dosage,
    required this.frequency,
    this.duration,
    this.instructions,
    this.prescribedDate,
    this.startDate,
    this.endDate,
    this.quantity,
    this.refills,
    this.status,
  });

  // Convert to Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encounterId': encounterId,
      'medicationId': medicationId,
      'patientId': patientId,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'prescribedDate': prescribedDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'quantity': quantity,
      'refills': refills,
      'status': status,
    };
  }

  // Create from Map for API responses
  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id']?.toInt(),
      encounterId: map['encounterId']?.toInt() ?? 0,
      medicationId: map['medicationId']?.toInt() ?? 0,
      patientId: map['patientId']?.toInt() ?? 0,
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'],
      instructions: map['instructions'],
      prescribedDate: map['prescribedDate'] != null
          ? DateTime.parse(map['prescribedDate'])
          : null,
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      quantity: map['quantity']?.toInt(),
      refills: map['refills']?.toInt(),
      status: map['status'],
    );
  }

  // Convert to JSON string
  String toJson() => toMap().toString();

  // Create from JSON string
  factory Prescription.fromJson(Map<String, dynamic> json) =>
      Prescription.fromMap(json);

  // Check if prescription is active
  bool get isActive => status?.toLowerCase() == 'active';

  // Check if prescription is completed
  bool get isCompleted => status?.toLowerCase() == 'completed';

  // Check if prescription is discontinued
  bool get isDiscontinued => status?.toLowerCase() == 'discontinued';

  // Get days remaining if duration is specified
  int? get daysRemaining {
    if (startDate != null && duration != null) {
      final durationDays = _parseDurationToDays(duration!);
      if (durationDays != null) {
        final endDate = startDate!.add(Duration(days: durationDays));
        final now = DateTime.now();
        if (endDate.isAfter(now)) {
          return endDate.difference(now).inDays;
        }
      }
    }
    return null;
  }

  // Helper method to parse duration string to days
  int? _parseDurationToDays(String duration) {
    final regex = RegExp(r'(\d+)\s*(day|days|week|weeks|month|months)');
    final match = regex.firstMatch(duration.toLowerCase());
    if (match != null) {
      final value = int.tryParse(match.group(1) ?? '');
      final unit = match.group(2);
      if (value != null) {
        switch (unit) {
          case 'day':
          case 'days':
            return value;
          case 'week':
          case 'weeks':
            return value * 7;
          case 'month':
          case 'months':
            return value * 30; // Approximate
        }
      }
    }
    return null;
  }

  // Create a copy with updated fields
  Prescription copyWith({
    int? id,
    int? encounterId,
    int? medicationId,
    int? patientId,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
    DateTime? prescribedDate,
    DateTime? startDate,
    DateTime? endDate,
    int? quantity,
    int? refills,
    String? status,
  }) {
    return Prescription(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      medicationId: medicationId ?? this.medicationId,
      patientId: patientId ?? this.patientId,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      prescribedDate: prescribedDate ?? this.prescribedDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      quantity: quantity ?? this.quantity,
      refills: refills ?? this.refills,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Prescription{id: $id, dosage: $dosage, frequency: $frequency, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prescription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
