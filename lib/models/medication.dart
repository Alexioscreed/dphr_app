class Medication {
  final int? id;
  final String? name; // Medication name for reference
  final String? genericName; // Generic name
  final String? strength; // e.g., "500mg", "10mg"
  final String? form; // e.g., "Tablet", "Capsule", "Injection"
  final String? manufacturer; // Manufacturer name
  final int? encounterId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String route;
  final String prescribedBy;
  final DateTime? prescribedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String instructions;
  final String indication;
  final String status;
  final int quantity;
  final int refills;
  final String notes;

  Medication({
    this.id,
    this.name,
    this.genericName,
    this.strength,
    this.form,
    this.manufacturer,
    this.encounterId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.prescribedBy,
    this.prescribedDate,
    this.startDate,
    this.endDate,
    required this.instructions,
    required this.indication,
    required this.status,
    required this.quantity,
    required this.refills,
    required this.notes,
  });
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id']?.toInt(),
      name: map['name'],
      genericName: map['genericName'],
      strength: map['strength'],
      form: map['form'],
      manufacturer: map['manufacturer'],
      encounterId: map['encounterId']?.toInt(),
      medicationName: map['medicationName'] ?? map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      route: map['route'] ?? '',
      prescribedBy: map['prescribedBy'] ?? '',
      prescribedDate: map['prescribedDate'] != null
          ? DateTime.parse(map['prescribedDate'])
          : null,
      startDate:
          map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      instructions: map['instructions'] ?? '',
      indication: map['indication'] ?? '',
      status: map['status'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      refills: map['refills']?.toInt() ?? 0,
      notes: map['notes'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'strength': strength,
      'form': form,
      'manufacturer': manufacturer,
      'encounterId': encounterId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'route': route,
      'prescribedBy': prescribedBy,
      'prescribedDate': prescribedDate?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
      'indication': indication,
      'status': status,
      'quantity': quantity,
      'refills': refills,
      'notes': notes,
    };
  }
}
