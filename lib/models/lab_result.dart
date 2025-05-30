class LabResult {
  final int? id;
  final int encounterId;
  final String testName;
  final String testCode;
  final String value;
  final String normalRange;
  final String unit;
  final String status;
  final DateTime? collectionDateTime;
  final DateTime? resultDateTime;
  final String laboratory;
  final String technician;
  final String notes;

  LabResult({
    this.id,
    required this.encounterId,
    required this.testName,
    required this.testCode,
    required this.value,
    required this.normalRange,
    required this.unit,
    required this.status,
    this.collectionDateTime,
    this.resultDateTime,
    required this.laboratory,
    required this.technician,
    required this.notes,
  });
  factory LabResult.fromMap(Map<String, dynamic> map) {
    return LabResult(
      id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      encounterId: map['encounterId'] is int ? map['encounterId'] : (map['encounterId'] != null ? int.tryParse(map['encounterId'].toString()) ?? 0 : 0),
      testName: map['testName'] ?? '',
      testCode: map['testCode'] ?? '',
      value: map['value'] ?? '',
      normalRange: map['normalRange'] ?? '',
      unit: map['unit'] ?? '',
      status: map['status'] ?? '',
      collectionDateTime: map['collectionDateTime'] != null
          ? DateTime.parse(map['collectionDateTime'])
          : null,
      resultDateTime: map['resultDateTime'] != null
          ? DateTime.parse(map['resultDateTime'])
          : null,
      laboratory: map['laboratory'] ?? '',
      technician: map['technician'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encounterId': encounterId,
      'testName': testName,
      'testCode': testCode,
      'value': value,
      'normalRange': normalRange,
      'unit': unit,
      'status': status,
      'collectionDateTime': collectionDateTime?.toIso8601String(),
      'resultDateTime': resultDateTime?.toIso8601String(),
      'laboratory': laboratory,
      'technician': technician,
      'notes': notes,
    };
  }
}
