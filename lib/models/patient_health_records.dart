class PatientDemographics {
  final String uuid;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? gender;
  final String? birthdate;
  final int? age;
  final String? mrn;
  final String? phoneNumber;
  final String? address;
  final List<String>? identifiers;

  PatientDemographics({
    required this.uuid,
    this.firstName,
    this.lastName,
    this.fullName,
    this.gender,
    this.birthdate,
    this.age,
    this.mrn,
    this.phoneNumber,
    this.address,
    this.identifiers,
  });

  factory PatientDemographics.fromJson(Map<String, dynamic> json) {
    return PatientDemographics(
      uuid: json['uuid'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      age: json['age'],
      mrn: json['mrn'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      identifiers: json['identifiers'] != null
          ? List<String>.from(json['identifiers'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'gender': gender,
      'birthdate': birthdate,
      'age': age,
      'mrn': mrn,
      'phoneNumber': phoneNumber,
      'address': address,
      'identifiers': identifiers,
    };
  }
}

class ObservationRecord {
  final String? uuid;
  final String? concept;
  final String? conceptDisplay;
  final dynamic value;
  final String? valueDisplay;
  final String? obsDate;
  final String? units;
  final String? normalRange;
  final String? comment;
  final String? category;

  ObservationRecord({
    this.uuid,
    this.concept,
    this.conceptDisplay,
    this.value,
    this.valueDisplay,
    this.obsDate,
    this.units,
    this.normalRange,
    this.comment,
    this.category,
  });

  factory ObservationRecord.fromJson(Map<String, dynamic> json) {
    return ObservationRecord(
      uuid: json['uuid'],
      concept: json['concept'],
      conceptDisplay: json['conceptDisplay'],
      value: json['value'],
      valueDisplay: json['valueDisplay'],
      obsDate: json['obsDate'],
      units: json['units'],
      normalRange: json['normalRange'],
      comment: json['comment'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'concept': concept,
      'conceptDisplay': conceptDisplay,
      'value': value,
      'valueDisplay': valueDisplay,
      'obsDate': obsDate,
      'units': units,
      'normalRange': normalRange,
      'comment': comment,
      'category': category,
    };
  }
}

class OrderRecord {
  final String? uuid;
  final String? concept;
  final String? conceptDisplay;
  final String? instructions;
  final String? orderType;
  final String? dateActivated;
  final String? urgency;
  final String? action;
  final String? dosage;
  final String? frequency;
  final String? duration;

  OrderRecord({
    this.uuid,
    this.concept,
    this.conceptDisplay,
    this.instructions,
    this.orderType,
    this.dateActivated,
    this.urgency,
    this.action,
    this.dosage,
    this.frequency,
    this.duration,
  });

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    return OrderRecord(
      uuid: json['uuid'],
      concept: json['concept'],
      conceptDisplay: json['conceptDisplay'],
      instructions: json['instructions'],
      orderType: json['orderType'],
      dateActivated: json['dateActivated'],
      urgency: json['urgency'],
      action: json['action'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'concept': concept,
      'conceptDisplay': conceptDisplay,
      'instructions': instructions,
      'orderType': orderType,
      'dateActivated': dateActivated,
      'urgency': urgency,
      'action': action,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}

class EncounterRecord {
  final String? encounterUuid;
  final String? encounterType;
  final String? encounterDate;
  final String? startDatetime;
  final String? stopDatetime;
  final String? location;
  final String? provider;
  final List<String>? diagnoses;
  final List<ObservationRecord>? observations;
  final List<OrderRecord>? prescriptions;
  final String? clinicalNotes;
  final String?
      formattedPrescriptions; // New field for formatted prescription text
  final String? status;

  EncounterRecord({
    this.encounterUuid,
    this.encounterType,
    this.encounterDate,
    this.startDatetime,
    this.stopDatetime,
    this.location,
    this.provider,
    this.diagnoses,
    this.observations,
    this.prescriptions,
    this.clinicalNotes,
    this.formattedPrescriptions,
    this.status,
  });
  factory EncounterRecord.fromJson(Map<String, dynamic> json) {
    return EncounterRecord(
      encounterUuid: json['encounterUuid'],
      encounterType: json['encounterType'],
      encounterDate: json['encounterDate'],
      startDatetime: json['startDatetime'],
      stopDatetime: json['stopDatetime'],
      location: json['location'],
      provider: json['provider'],
      diagnoses: json['diagnoses'] != null
          ? List<String>.from(json['diagnoses'])
          : null,
      observations: json['observations'] != null
          ? (json['observations'] as List)
              .map((obs) => ObservationRecord.fromJson(obs))
              .toList()
          : null,
      prescriptions: json['prescriptions'] != null
          ? (json['prescriptions'] as List)
              .map((pres) => OrderRecord.fromJson(pres))
              .toList()
          : null,
      clinicalNotes: json['clinicalNotes'],
      formattedPrescriptions: json['formattedPrescriptions'],
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'encounterUuid': encounterUuid,
      'encounterType': encounterType,
      'encounterDate': encounterDate,
      'startDatetime': startDatetime,
      'stopDatetime': stopDatetime,
      'location': location,
      'provider': provider,
      'diagnoses': diagnoses,
      'observations': observations?.map((obs) => obs.toJson()).toList(),
      'prescriptions': prescriptions?.map((pres) => pres.toJson()).toList(),
      'clinicalNotes': clinicalNotes,
      'formattedPrescriptions': formattedPrescriptions,
      'status': status,
    };
  }
}

class VisitRecord {
  final String? visitUuid;
  final String? visitType;
  final String? location;
  final String? startDate;
  final String? startDatetime;
  final String? endDate;
  final String? stopDatetime;
  final String? status;
  final List<EncounterRecord>? encounters;
  final PatientDemographics? patientInfo;

  VisitRecord({
    this.visitUuid,
    this.visitType,
    this.location,
    this.startDate,
    this.startDatetime,
    this.endDate,
    this.stopDatetime,
    this.status,
    this.encounters,
    this.patientInfo,
  });
  factory VisitRecord.fromJson(Map<String, dynamic> json) {
    return VisitRecord(
      visitUuid: json['visitUuid'],
      visitType: json['visitType'],
      location: json['location'],
      startDate: json['startDate'],
      startDatetime: json['startDatetime'],
      endDate: json['endDate'],
      stopDatetime: json['stopDatetime'],
      status: json['status'],
      encounters: json['encounters'] != null
          ? (json['encounters'] as List)
              .map((enc) => EncounterRecord.fromJson(enc))
              .toList()
          : null,
      patientInfo: json['patientInfo'] != null
          ? PatientDemographics.fromJson(json['patientInfo'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'visitUuid': visitUuid,
      'visitType': visitType,
      'location': location,
      'startDate': startDate,
      'startDatetime': startDatetime,
      'endDate': endDate,
      'stopDatetime': stopDatetime,
      'status': status,
      'encounters': encounters?.map((enc) => enc.toJson()).toList(),
      'patientInfo': patientInfo?.toJson(),
    };
  }
}

class PatientHealthRecords {
  final PatientDemographics? demographics;
  final List<VisitRecord>? visits;
  final int? totalVisits;
  final String? lastVisitDate;
  final String? source;

  PatientHealthRecords({
    this.demographics,
    this.visits,
    this.totalVisits,
    this.lastVisitDate,
    this.source,
  });

  factory PatientHealthRecords.fromJson(Map<String, dynamic> json) {
    return PatientHealthRecords(
      demographics: json['demographics'] != null
          ? PatientDemographics.fromJson(json['demographics'])
          : null,
      visits: json['visits'] != null
          ? (json['visits'] as List)
              .map((visit) => VisitRecord.fromJson(visit))
              .toList()
          : null,
      totalVisits: json['totalVisits'],
      lastVisitDate: json['lastVisitDate'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'demographics': demographics?.toJson(),
      'visits': visits?.map((visit) => visit.toJson()).toList(),
      'totalVisits': totalVisits,
      'lastVisitDate': lastVisitDate,
      'source': source,
    };
  }
}
