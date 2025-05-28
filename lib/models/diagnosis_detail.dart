class DiagnosisDetail {
  final int? id;
  final int encounterId;
  final String diagnosisCode;
  final String diagnosisName;
  final String description;
  final String severity;
  final String status;
  final DateTime? diagnosedDate;
  final String diagnosedBy;
  final String category;
  final String notes;
  final DateTime? onsetDate;

  DiagnosisDetail({
    this.id,
    required this.encounterId,
    required this.diagnosisCode,
    required this.diagnosisName,
    required this.description,
    required this.severity,
    required this.status,
    this.diagnosedDate,
    required this.diagnosedBy,
    required this.category,
    required this.notes,
    this.onsetDate,
  });

  factory DiagnosisDetail.fromMap(Map<String, dynamic> map) {
    return DiagnosisDetail(
      id: map['id']?.toInt(),
      encounterId: map['encounterId']?.toInt() ?? 0,
      diagnosisCode: map['diagnosisCode'] ?? '',
      diagnosisName: map['diagnosisName'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? '',
      status: map['status'] ?? '',
      diagnosedDate: map['diagnosedDate'] != null
          ? DateTime.parse(map['diagnosedDate'])
          : null,
      diagnosedBy: map['diagnosedBy'] ?? '',
      category: map['category'] ?? '',
      notes: map['notes'] ?? '',
      onsetDate:
          map['onsetDate'] != null ? DateTime.parse(map['onsetDate']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encounterId': encounterId,
      'diagnosisCode': diagnosisCode,
      'diagnosisName': diagnosisName,
      'description': description,
      'severity': severity,
      'status': status,
      'diagnosedDate': diagnosedDate?.toIso8601String(),
      'diagnosedBy': diagnosedBy,
      'category': category,
      'notes': notes,
      'onsetDate': onsetDate?.toIso8601String(),
    };
  }
}
