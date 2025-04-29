// Client Registry Models
class ClientRegistration {
  final FacilityDetails facilityDetails;
  final DemographicDetails demographicDetails;

  ClientRegistration({
    required this.facilityDetails,
    required this.demographicDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'facilityDetails': facilityDetails.toJson(),
      'demographicDetails': demographicDetails.toJson(),
    };
  }
}

class ClientRegistrationResponse {
  final String status;
  final String message;
  final String? clientId;
  final List<String>? errors;

  ClientRegistrationResponse({
    required this.status,
    required this.message,
    this.clientId,
    this.errors,
  });

  factory ClientRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return ClientRegistrationResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      clientId: json['clientId'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class ClientResponse {
  final String status;
  final String message;
  final ClientData? data;
  final List<String>? errors;

  ClientResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ClientResponse.fromJson(Map<String, dynamic> json) {
    return ClientResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? ClientData.fromJson(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class ClientData {
  final String clientId;
  final FacilityDetails facilityDetails;
  final DemographicDetails demographicDetails;

  ClientData({
    required this.clientId,
    required this.facilityDetails,
    required this.demographicDetails,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      clientId: json['clientId'] ?? '',
      facilityDetails: FacilityDetails.fromJson(json['facilityDetails']),
      demographicDetails: DemographicDetails.fromJson(json['demographicDetails']),
    );
  }
}

class FacilityDetails {
  final String code;
  final String name;

  FacilityDetails({
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  factory FacilityDetails.fromJson(Map<String, dynamic> json) {
    return FacilityDetails(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class DemographicDetails {
  final String mrn;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final List<String>? phoneNumbers;
  final List<String>? emails;
  final String? occupation;
  final String? maritalStatus;
  final String? nationality;
  final List<Address>? addresses;
  final List<Identifier> identifiers;
  final List<ContactPerson>? contactPeople;
  final List<PaymentDetail>? paymentDetails;

  DemographicDetails({
    required this.mrn,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.phoneNumbers,
    this.emails,
    this.occupation,
    this.maritalStatus,
    this.nationality,
    this.addresses,
    required this.identifiers,
    this.contactPeople,
    this.paymentDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'mrn': mrn,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'phoneNumbers': phoneNumbers,
      'emails': emails,
      'occupation': occupation,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'addresses': addresses?.map((a) => a.toJson()).toList(),
      'identifiers': identifiers.map((i) => i.toJson()).toList(),
      'contactPeople': contactPeople?.map((c) => c.toJson()).toList(),
      'paymentDetails': paymentDetails?.map((p) => p.toJson()).toList(),
    };
  }

  factory DemographicDetails.fromJson(Map<String, dynamic> json) {
    return DemographicDetails(
      mrn: json['mrn'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      lastName: json['lastName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      phoneNumbers: json['phoneNumbers'] != null ? List<String>.from(json['phoneNumbers']) : null,
      emails: json['emails'] != null ? List<String>.from(json['emails']) : null,
      occupation: json['occupation'],
      maritalStatus: json['maritalStatus'],
      nationality: json['nationality'],
      addresses: json['addresses'] != null
          ? (json['addresses'] as List).map((a) => Address.fromJson(a)).toList()
          : null,
      identifiers: json['identifiers'] != null
          ? (json['identifiers'] as List).map((i) => Identifier.fromJson(i)).toList()
          : [],
      contactPeople: json['contactPeople'] != null
          ? (json['contactPeople'] as List).map((c) => ContactPerson.fromJson(c)).toList()
          : null,
      paymentDetails: json['paymentDetails'] != null
          ? (json['paymentDetails'] as List).map((p) => PaymentDetail.fromJson(p)).toList()
          : null,
    );
  }
}

class Address {
  final String type;
  final String? line1;
  final String? line2;
  final String? city;
  final String? district;
  final String? region;
  final String? country;
  final String? postalCode;

  Address({
    required this.type,
    this.line1,
    this.line2,
    this.city,
    this.district,
    this.region,
    this.country,
    this.postalCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'line1': line1,
      'line2': line2,
      'city': city,
      'district': district,
      'region': region,
      'country': country,
      'postalCode': postalCode,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      type: json['type'] ?? '',
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      district: json['district'],
      region: json['region'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }
}

class Identifier {
  final String type;
  final String id;
  final bool preferred;

  Identifier({
    required this.type,
    required this.id,
    required this.preferred,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'preferred': preferred,
    };
  }

  factory Identifier.fromJson(Map<String, dynamic> json) {
    return Identifier(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      preferred: json['preferred'] ?? false,
    );
  }
}

class ContactPerson {
  final String name;
  final String relationship;
  final String? phoneNumber;
  final String? email;

  ContactPerson({
    required this.name,
    required this.relationship,
    this.phoneNumber,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }
}

class PaymentDetail {
  final String type;
  final String? insuranceProvider;
  final String? membershipNumber;
  final String? expiryDate;

  PaymentDetail({
    required this.type,
    this.insuranceProvider,
    this.membershipNumber,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'insuranceProvider': insuranceProvider,
      'membershipNumber': membershipNumber,
      'expiryDate': expiryDate,
    };
  }

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      type: json['type'] ?? '',
      insuranceProvider: json['insuranceProvider'],
      membershipNumber: json['membershipNumber'],
      expiryDate: json['expiryDate'],
    );
  }
}

// Shared Health Record Models
class SharedRecordsResponse {
  final String status;
  final String message;
  final List<HealthRecordData>? results;
  final List<String>? errors;

  SharedRecordsResponse({
    required this.status,
    required this.message,
    this.results,
    this.errors,
  });

  factory SharedRecordsResponse.fromJson(Map<String, dynamic> json) {
    return SharedRecordsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      results: json['results'] != null
          ? (json['results'] as List).map((r) => HealthRecordData.fromJson(r)).toList()
          : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class HealthRecordData {
  final FacilityDetails facilityDetails;
  final VisitDetails visitDetails;
  final List<DiagnosisDetail>? diagnosisDetails;
  final ClinicalInformation? clinicalInformation;
  final List<InvestigationDetail>? investigationDetails;
  final List<LabInvestigationDetail>? labInvestigationDetails;
  final List<MedicationDetail>? medicationDetails;
  final TreatmentDetails? treatmentDetails;
  final List<RadiologyDetail>? radiologyDetails;
  final AdmissionDetails? admissionDetails;
  final OutcomeDetails? outcomeDetails;
  final List<BillingDetail>? billingDetails;

  HealthRecordData({
    required this.facilityDetails,
    required this.visitDetails,
    this.diagnosisDetails,
    this.clinicalInformation,
    this.investigationDetails,
    this.labInvestigationDetails,
    this.medicationDetails,
    this.treatmentDetails,
    this.radiologyDetails,
    this.admissionDetails,
    this.outcomeDetails,
    this.billingDetails,
  });

  factory HealthRecordData.fromJson(Map<String, dynamic> json) {
    return HealthRecordData(
      facilityDetails: FacilityDetails.fromJson(json['facilityDetails']),
      visitDetails: VisitDetails.fromJson(json['visitDetails']),
      diagnosisDetails: json['diagnosisDetails'] != null
          ? (json['diagnosisDetails'] as List).map((d) => DiagnosisDetail.fromJson(d)).toList()
          : null,
      clinicalInformation: json['clinicalInformation'] != null
          ? ClinicalInformation.fromJson(json['clinicalInformation'])
          : null,
      investigationDetails: json['investigationDetails'] != null
          ? (json['investigationDetails'] as List).map((i) => InvestigationDetail.fromJson(i)).toList()
          : null,
      labInvestigationDetails: json['labInvestigationDetails'] != null
          ? (json['labInvestigationDetails'] as List).map((l) => LabInvestigationDetail.fromJson(l)).toList()
          : null,
      medicationDetails: json['medicationDetails'] != null
          ? (json['medicationDetails'] as List).map((m) => MedicationDetail.fromJson(m)).toList()
          : null,
      treatmentDetails: json['treatmentDetails'] != null
          ? TreatmentDetails.fromJson(json['treatmentDetails'])
          : null,
      radiologyDetails: json['radiologyDetails'] != null
          ? (json['radiologyDetails'] as List).map((r) => RadiologyDetail.fromJson(r)).toList()
          : null,
      admissionDetails: json['admissionDetails'] != null
          ? AdmissionDetails.fromJson(json['admissionDetails'])
          : null,
      outcomeDetails: json['outcomeDetails'] != null
          ? OutcomeDetails.fromJson(json['outcomeDetails'])
          : null,
      billingDetails: json['billingDetails'] != null
          ? (json['billingDetails'] as List).map((b) => BillingDetail.fromJson(b)).toList()
          : null,
    );
  }
}

class VisitDetails {
  final String id;
  final String visitDate;
  final bool newThisYear;
  final bool isNew;
  final String visitType;

  VisitDetails({
    required this.id,
    required this.visitDate,
    required this.newThisYear,
    required this.isNew,
    required this.visitType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitDate': visitDate,
      'newThisYear': newThisYear,
      'new': isNew,
      'visitType': visitType,
    };
  }

  factory VisitDetails.fromJson(Map<String, dynamic> json) {
    return VisitDetails(
      id: json['id'] ?? '',
      visitDate: json['visitDate'] ?? '',
      newThisYear: json['newThisYear'] ?? false,
      isNew: json['new'] ?? false,
      visitType: json['visitType'] ?? '',
    );
  }
}

class DiagnosisDetail {
  final String certainty;
  final String diagnosis;
  final String diagnosisCode;
  final String diagnosisDate;
  final String diagnosisDescription;

  DiagnosisDetail({
    required this.certainty,
    required this.diagnosis,
    required this.diagnosisCode,
    required this.diagnosisDate,
    required this.diagnosisDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'certainty': certainty,
      'diagnosis': diagnosis,
      'diagnosisCode': diagnosisCode,
      'diagnosisDate': diagnosisDate,
      'diagnosisDescription': diagnosisDescription,
    };
  }

  factory DiagnosisDetail.fromJson(Map<String, dynamic> json) {
    return DiagnosisDetail(
      certainty: json['certainty'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      diagnosisCode: json['diagnosisCode'] ?? '',
      diagnosisDate: json['diagnosisDate'] ?? '',
      diagnosisDescription: json['diagnosisDescription'] ?? '',
    );
  }
}

class ClinicalInformation {
  final List<VitalSign>? vitalSigns;
  final List<VisitNote>? visitNotes;

  ClinicalInformation({
    this.vitalSigns,
    this.visitNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'vitalSigns': vitalSigns?.map((v) => v.toJson()).toList(),
      'visitNotes': visitNotes?.map((n) => n.toJson()).toList(),
    };
  }

  factory ClinicalInformation.fromJson(Map<String, dynamic> json) {
    return ClinicalInformation(
      vitalSigns: json['vitalSigns'] != null
          ? (json['vitalSigns'] as List).map((v) => VitalSign.fromJson(v)).toList()
          : null,
      visitNotes: json['visitNotes'] != null
          ? (json['visitNotes'] as List).map((n) => VisitNote.fromJson(n)).toList()
          : null,
    );
  }
}

class VitalSign {
  final String? bloodPressure;
  final String? weight;
  final String? temperature;
  final String? height;
  final String? respiration;
  final String? pulseRate;
  final String dateTime;

  VitalSign({
    this.bloodPressure,
    this.weight,
    this.temperature,
    this.height,
    this.respiration,
    this.pulseRate,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'bloodPressure': bloodPressure,
      'weight': weight,
      'temperature': temperature,
      'height': height,
      'respiration': respiration,
      'pulseRate': pulseRate,
      'dateTime': dateTime,
    };
  }

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      bloodPressure: json['bloodPressure'],
      weight: json['weight'],
      temperature: json['temperature'],
      height: json['height'],
      respiration: json['respiration'],
      pulseRate: json['pulseRate'],
      dateTime: json['dateTime'] ?? '',
    );
  }
}

class VisitNote {
  final String note;
  final String dateTime;

  VisitNote({
    required this.note,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'dateTime': dateTime,
    };
  }

  factory VisitNote.fromJson(Map<String, dynamic> json) {
    return VisitNote(
      note: json['note'] ?? '',
      dateTime: json['dateTime'] ?? '',
    );
  }
}

class InvestigationDetail {
  final String investigation;
  final String result;
  final String dateTime;

  InvestigationDetail({
    required this.investigation,
    required this.result,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'investigation': investigation,
      'result': result,
      'dateTime': dateTime,
    };
  }

  factory InvestigationDetail.fromJson(Map<String, dynamic> json) {
    return InvestigationDetail(
      investigation: json['investigation'] ?? '',
      result: json['result'] ?? '',
      dateTime: json['dateTime'] ?? '',
    );
  }
}

class LabInvestigationDetail {
  final String test;
  final String result;
  final String units;
  final String referenceRange;
  final String dateTime;

  LabInvestigationDetail({
    required this.test,
    required this.result,
    required this.units,
    required this.referenceRange,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'test': test,
      'result': result,
      'units': units,
      'referenceRange': referenceRange,
      'dateTime': dateTime,
    };
  }

  factory LabInvestigationDetail.fromJson(Map<String, dynamic> json) {
    return LabInvestigationDetail(
      test: json['test'] ?? '',
      result: json['result'] ?? '',
      units: json['units'] ?? '',
      referenceRange: json['referenceRange'] ?? '',
      dateTime: json['dateTime'] ?? '',
    );
  }
}

class MedicationDetail {
  final String medication;
  final String dosage;
  final String frequency;
  final String duration;
  final String startDate;
  final String? endDate;

  MedicationDetail({
    required this.medication,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'medication': medication,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  factory MedicationDetail.fromJson(Map<String, dynamic> json) {
    return MedicationDetail(
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
    );
  }
}

class TreatmentDetails {
  final String? procedure;
  final String? dateTime;
  final String? notes;

  TreatmentDetails({
    this.procedure,
    this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'procedure': procedure,
      'dateTime': dateTime,
      'notes': notes,
    };
  }

  factory TreatmentDetails.fromJson(Map<String, dynamic> json) {
    return TreatmentDetails(
      procedure: json['procedure'],
      dateTime: json['dateTime'],
      notes: json['notes'],
    );
  }
}

class RadiologyDetail {
  final String examination;
  final String result;
  final String dateTime;

  RadiologyDetail({
    required this.examination,
    required this.result,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'examination': examination,
      'result': result,
      'dateTime': dateTime,
    };
  }

  factory RadiologyDetail.fromJson(Map<String, dynamic> json) {
    return RadiologyDetail(
      examination: json['examination'] ?? '',
      result: json['result'] ?? '',
      dateTime: json['dateTime'] ?? '',
    );
  }
}

class AdmissionDetails {
  final String? admissionDate;
  final String? dischargeDate;
  final String? ward;
  final String? bedNumber;
  final String? notes;

  AdmissionDetails({
    this.admissionDate,
    this.dischargeDate,
    this.ward,
    this.bedNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'admissionDate': admissionDate,
      'dischargeDate': dischargeDate,
      'ward': ward,
      'bedNumber': bedNumber,
      'notes': notes,
    };
  }

  factory AdmissionDetails.fromJson(Map<String, dynamic> json) {
    return AdmissionDetails(
      admissionDate: json['admissionDate'],
      dischargeDate: json['dischargeDate'],
      ward: json['ward'],
      bedNumber: json['bedNumber'],
      notes: json['notes'],
    );
  }
}

class OutcomeDetails {
  final bool isAlive;
  final bool referred;
  final String? referredTo;
  final String? referralReason;
  final String? deathDate;
  final String? causeOfDeath;

  OutcomeDetails({
    required this.isAlive,
    required this.referred,
    this.referredTo,
    this.referralReason,
    this.deathDate,
    this.causeOfDeath,
  });

  Map<String, dynamic> toJson() {
    return {
      'isAlive': isAlive,
      'referred': referred,
      'referredTo': referredTo,
      'referralReason': referralReason,
      'deathDate': deathDate,
      'causeOfDeath': causeOfDeath,
    };
  }

  factory OutcomeDetails.fromJson(Map<String, dynamic> json) {
    return OutcomeDetails(
      isAlive: json['isAlive'] ?? true,
      referred: json['referred'] ?? false,
      referredTo: json['referredTo'],
      referralReason: json['referralReason'],
      deathDate: json['deathDate'],
      causeOfDeath: json['causeOfDeath'],
    );
  }
}

class BillingDetail {
  final String item;
  final double amount;
  final String currency;
  final String dateTime;
  final String paymentStatus;

  BillingDetail({
    required this.item,
    required this.amount,
    required this.currency,
    required this.dateTime,
    required this.paymentStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'amount': amount,
      'currency': currency,
      'dateTime': dateTime,
      'paymentStatus': paymentStatus,
    };
  }

  factory BillingDetail.fromJson(Map<String, dynamic> json) {
    return BillingDetail(
      item: json['item'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      dateTime: json['dateTime'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
    );
  }
}

// Health Record Submission
class HealthRecordSubmission {
  final TemplateDetails templateDetails;
  final SubmissionData data;

  HealthRecordSubmission({
    required this.templateDetails,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'templateDetails': templateDetails.toJson(),
      'data': data.toJson(),
    };
  }
}

class TemplateDetails {
  final String code;
  final String id;
  final String name;
  final WorkflowDetails workflow;

  TemplateDetails({
    required this.code,
    required this.id,
    required this.name,
    required this.workflow,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'id': id,
      'name': name,
      'workflow': workflow.toJson(),
    };
  }

  factory TemplateDetails.fromJson(Map<String, dynamic> json) {
    return TemplateDetails(
      code: json['code'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      workflow: WorkflowDetails.fromJson(json['workflow']),
    );
  }
}

class WorkflowDetails {
  final String uuid;

  WorkflowDetails({
    required this.uuid,
  });

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
    };
  }

  factory WorkflowDetails.fromJson(Map<String, dynamic> json) {
    return WorkflowDetails(
      uuid: json['uuid'] ?? '',
    );
  }
}

class SubmissionData {
  final FacilityDetails facilityDetails;
  final ReportDetails reportDetails;
  final List<ListGridItem> listGrid;

  SubmissionData({
    required this.facilityDetails,
    required this.reportDetails,
    required this.listGrid,
  });

  Map<String, dynamic> toJson() {
    return {
      'facilityDetails': facilityDetails.toJson(),
      'reportDetails': reportDetails.toJson(),
      'listGrid': listGrid.map((item) => item.toJson()).toList(),
    };
  }
}

class ReportDetails {
  final String reportingDate;

  ReportDetails({
    required this.reportingDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportingDate': reportingDate,
    };
  }

  factory ReportDetails.fromJson(Map<String, dynamic> json) {
    return ReportDetails(
      reportingDate: json['reportingDate'] ?? '',
    );
  }
}

class ListGridItem {
  final DemographicDetails demographicDetails;
  final VisitDetails visitDetails;
  final List<DiagnosisDetail>? diagnosisDetails;
  final ClinicalInformation? clinicalInformation;
  final List<InvestigationDetail>? investigationDetails;
  final List<LabInvestigationDetail>? labInvestigationDetails;
  final List<MedicationDetail>? medicationDetails;
  final TreatmentDetails? treatmentDetails;
  final List<RadiologyDetail>? radiologyDetails;
  final AdmissionDetails? admissionDetails;
  final OutcomeDetails? outcomeDetails;
  final List<BillingDetail>? billingDetails;

  ListGridItem({
    required this.demographicDetails,
    required this.visitDetails,
    this.diagnosisDetails,
    this.clinicalInformation,
    this.investigationDetails,
    this.labInvestigationDetails,
    this.medicationDetails,
    this.treatmentDetails,
    this.radiologyDetails,
    this.admissionDetails,
    this.outcomeDetails,
    this.billingDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'demographicDetails': demographicDetails.toJson(),
      'visitDetails': visitDetails.toJson(),
      'diagnosisDetails': diagnosisDetails?.map((d) => d.toJson()).toList(),
      'clinicalInformation': clinicalInformation?.toJson(),
      'investigationDetails': investigationDetails?.map((i) => i.toJson()).toList(),
      'labInvestigationDetails': labInvestigationDetails?.map((l) => l.toJson()).toList(),
      'medicationDetails': medicationDetails?.map((m) => m.toJson()).toList(),
      'treatmentDetails': treatmentDetails?.toJson(),
      'radiologyDetails': radiologyDetails?.map((r) => r.toJson()).toList(),
      'admissionDetails': admissionDetails?.toJson(),
      'outcomeDetails': outcomeDetails?.toJson(),
      'billingDetails': billingDetails?.map((b) => b.toJson()).toList(),
    };
  }
}

// Data Templates Response
class DataTemplatesResponse {
  final String status;
  final String message;
  final List<DataTemplateInfo>? templates;
  final List<String>? errors;

  DataTemplatesResponse({
    required this.status,
    required this.message,
    this.templates,
    this.errors,
  });

  factory DataTemplatesResponse.fromJson(Map<String, dynamic> json) {
    return DataTemplatesResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      templates: json['templates'] != null
          ? (json['templates'] as List).map((t) => DataTemplateInfo.fromJson(t)).toList()
          : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class DataTemplateInfo {
  final String id;
  final String code;
  final String name;
  final String description;
  final String version;

  DataTemplateInfo({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.version,
  });

  factory DataTemplateInfo.fromJson(Map<String, dynamic> json) {
    return DataTemplateInfo(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '',
    );
  }
}

class DataTemplateResponse {
  final String status;
  final String message;
  final DataTemplateDetail? template;
  final List<String>? errors;

  DataTemplateResponse({
    required this.status,
    required this.message,
    this.template,
    this.errors,
  });

  factory DataTemplateResponse.fromJson(Map<String, dynamic> json) {
    return DataTemplateResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      template: json['template'] != null ? DataTemplateDetail.fromJson(json['template']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class DataTemplateDetail {
  final String id;
  final String code;
  final String name;
  final String description;
  final String version;
  final Map<String, dynamic> schema;

  DataTemplateDetail({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.version,
    required this.schema,
  });

  factory DataTemplateDetail.fromJson(Map<String, dynamic> json) {
    return DataTemplateDetail(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '',
      schema: json['schema'] ?? {},
    );
  }
}

// Submit Record Response
class SubmitRecordResponse {
  final String status;
  final String message;
  final String? recordId;
  final List<String>? errors;

  SubmitRecordResponse({
    required this.status,
    required this.message,
    this.recordId,
    this.errors,
  });

  factory SubmitRecordResponse.fromJson(Map<String, dynamic> json) {
    return SubmitRecordResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      recordId: json['recordId'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

// Code System Response
class CodeSystemResponse {
  final String status;
  final String message;
  final List<CodeInfo>? codes;
  final Pagination? pagination;
  final List<String>? errors;

  CodeSystemResponse({
    required this.status,
    required this.message,
    this.codes,
    this.pagination,
    this.errors,
  });

  factory CodeSystemResponse.fromJson(Map<String, dynamic> json) {
    return CodeSystemResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      codes: json['codes'] != null
          ? (json['codes'] as List).map((c) => CodeInfo.fromJson(c)).toList()
          : null,
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class CodeInfo {
  final String code;
  final String display;
  final String? system;
  final String? version;

  CodeInfo({
    required this.code,
    required this.display,
    this.system,
    this.version,
  });

  factory CodeInfo.fromJson(Map<String, dynamic> json) {
    return CodeInfo(
      code: json['code'] ?? '',
      display: json['display'] ?? '',
      system: json['system'],
      version: json['version'],
    );
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
    );
  }
}

// Referral Models
class ReferralSubmission {
  final FacilityDetails fromFacility;
  final FacilityDetails toFacility;
  final DemographicDetails patientDetails;
  final String referralDate;
  final String referralReason;
  final List<DiagnosisDetail>? diagnosisDetails;
  final List<MedicationDetail>? medicationDetails;
  final List<InvestigationDetail>? investigationDetails;
  final String? notes;

  ReferralSubmission({
    required this.fromFacility,
    required this.toFacility,
    required this.patientDetails,
    required this.referralDate,
    required this.referralReason,
    this.diagnosisDetails,
    this.medicationDetails,
    this.investigationDetails,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromFacility': fromFacility.toJson(),
      'toFacility': toFacility.toJson(),
      'patientDetails': patientDetails.toJson(),
      'referralDate': referralDate,
      'referralReason': referralReason,
      'diagnosisDetails': diagnosisDetails?.map((d) => d.toJson()).toList(),
      'medicationDetails': medicationDetails?.map((m) => m.toJson()).toList(),
      'investigationDetails': investigationDetails?.map((i) => i.toJson()).toList(),
      'notes': notes,
    };
  }
}

class ReferralResponse {
  final String status;
  final String message;
  final String? referralId;
  final List<String>? errors;

  ReferralResponse({
    required this.status,
    required this.message,
    this.referralId,
    this.errors,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      referralId: json['referralId'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class ReferralsResponse {
  final String status;
  final String message;
  final List<ReferralInfo>? referrals;
  final List<String>? errors;

  ReferralsResponse({
    required this.status,
    required this.message,
    this.referrals,
    this.errors,
  });

  factory ReferralsResponse.fromJson(Map<String, dynamic> json) {
    return ReferralsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      referrals: json['referrals'] != null
          ? (json['referrals'] as List).map((r) => ReferralInfo.fromJson(r)).toList()
          : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class ReferralInfo {
  final String referralId;
  final FacilityDetails fromFacility;
  final FacilityDetails toFacility;
  final String referralDate;
  final String referralReason;
  final String status;
  final String? notes;

  ReferralInfo({
    required this.referralId,
    required this.fromFacility,
    required this.toFacility,
    required this.referralDate,
    required this.referralReason,
    required this.status,
    this.notes,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralId: json['referralId'] ?? '',
      fromFacility: FacilityDetails.fromJson(json['fromFacility']),
      toFacility: FacilityDetails.fromJson(json['toFacility']),
      referralDate: json['referralDate'] ?? '',
      referralReason: json['referralReason'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'],
    );
  }
}

