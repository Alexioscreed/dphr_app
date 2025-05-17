class HealthRecord {
  final String id;
  final String title;
  final DateTime date;
  final String provider;
  final String type;
  final String description;
  final List<String> attachments;

  HealthRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.provider,
    required this.type,
    required this.description,
    required this.attachments,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'provider': provider,
      'type': type,
      'description': description,
      'attachments': attachments,
    };
  }

  // Create from Map for database retrieval
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      provider: map['provider'],
      type: map['type'],
      description: map['description'],
      attachments: List<String>.from(map['attachments']),
    );
  }
}
