class VitalMeasurement {
  final String type;
  final String value;
  final DateTime date;
  final String notes;

  VitalMeasurement({
    required this.type,
    required this.value,
    required this.date,
    this.notes = '',
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from Map for database retrieval
  factory VitalMeasurement.fromMap(Map<String, dynamic> map) {
    return VitalMeasurement(
      type: map['type'],
      value: map['value'],
      date: DateTime.parse(map['date']),
      notes: map['notes'] ?? '',
    );
  }
}
