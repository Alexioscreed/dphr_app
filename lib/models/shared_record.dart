class SharedRecord {
  final String id;
  final String recipientName;
  final String recipientEmail;
  final String recordType;
  final DateTime sharedDate;
  final DateTime expiryDate;
  final String status;
  final String description;
  final List<String> files;

  SharedRecord({
    required this.id,
    required this.recipientName,
    required this.recipientEmail,
    required this.recordType,
    required this.sharedDate,
    required this.expiryDate,
    required this.status,
    required this.description,
    required this.files,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'recordType': recordType,
      'sharedDate': sharedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
      'description': description,
      'files': files,
    };
  }

  // Create from Map for database retrieval
  factory SharedRecord.fromMap(Map<String, dynamic> map) {
    return SharedRecord(
      id: map['id'],
      recipientName: map['recipientName'],
      recipientEmail: map['recipientEmail'],
      recordType: map['recordType'],
      sharedDate: DateTime.parse(map['sharedDate']),
      expiryDate: DateTime.parse(map['expiryDate']),
      status: map['status'],
      description: map['description'],
      files: List<String>.from(map['files']),
    );
  }
}
