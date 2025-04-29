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

  // Create a copy with modified fields
  HealthRecord copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? provider,
    String? type,
    String? description,
    List<String>? attachments,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      provider: provider ?? this.provider,
      type: type ?? this.type,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
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

  // Create from JSON
  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      provider: json['provider'],
      type: json['type'],
      description: json['description'],
      attachments: List<String>.from(json['attachments']),
    );
  }
}

