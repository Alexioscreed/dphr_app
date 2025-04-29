class Symptom {
  final String name;
  final int severity;
  final DateTime date;
  final String notes;

  Symptom({
    required this.name,
    required this.severity,
    required this.date,
    required this.notes,
  });

  // Create a copy with modified fields
  Symptom copyWith({
    String? name,
    int? severity,
    DateTime? date,
    String? notes,
  }) {
    return Symptom(
      name: name ?? this.name,
      severity: severity ?? this.severity,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from JSON
  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      name: json['name'],
      severity: json['severity'],
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}

