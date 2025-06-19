class Concept {
  final String uuid;
  final String display;
  final String? name;
  final List<ConceptName>? names;
  final List<ConceptDescription>? descriptions;
  final ConceptDatatype? datatype;
  final ConceptClass? conceptClass;
  final List<ConceptMapping>? mappings;

  Concept({
    required this.uuid,
    required this.display,
    this.name,
    this.names,
    this.descriptions,
    this.datatype,
    this.conceptClass,
    this.mappings,
  });

  factory Concept.fromJson(Map<String, dynamic> json) {
    return Concept(
      uuid: json['uuid'] ?? '',
      display: json['display'] ?? '',
      name: json['name'],
      names: json['names'] != null
          ? (json['names'] as List)
              .map((item) => ConceptName.fromJson(item))
              .toList()
          : null,
      descriptions: json['descriptions'] != null
          ? (json['descriptions'] as List)
              .map((item) => ConceptDescription.fromJson(item))
              .toList()
          : null,
      datatype: json['datatype'] != null
          ? ConceptDatatype.fromJson(json['datatype'])
          : null,
      conceptClass: json['conceptClass'] != null
          ? ConceptClass.fromJson(json['conceptClass'])
          : null,
      mappings: json['mappings'] != null
          ? (json['mappings'] as List)
              .map((item) => ConceptMapping.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'display': display,
      'name': name,
      'names': names?.map((item) => item.toJson()).toList(),
      'descriptions': descriptions?.map((item) => item.toJson()).toList(),
      'datatype': datatype?.toJson(),
      'conceptClass': conceptClass?.toJson(),
      'mappings': mappings?.map((item) => item.toJson()).toList(),
    };
  }
}

class ConceptName {
  final String? uuid;
  final String name;
  final String? locale;
  final bool? localePreferred;
  final String? conceptNameType;

  ConceptName({
    this.uuid,
    required this.name,
    this.locale,
    this.localePreferred,
    this.conceptNameType,
  });

  factory ConceptName.fromJson(Map<String, dynamic> json) {
    return ConceptName(
      uuid: json['uuid'],
      name: json['name'] ?? '',
      locale: json['locale'],
      localePreferred: json['localePreferred'],
      conceptNameType: json['conceptNameType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'locale': locale,
      'localePreferred': localePreferred,
      'conceptNameType': conceptNameType,
    };
  }
}

class ConceptDescription {
  final String? uuid;
  final String description;
  final String? locale;

  ConceptDescription({
    this.uuid,
    required this.description,
    this.locale,
  });

  factory ConceptDescription.fromJson(Map<String, dynamic> json) {
    return ConceptDescription(
      uuid: json['uuid'],
      description: json['description'] ?? '',
      locale: json['locale'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'description': description,
      'locale': locale,
    };
  }
}

class ConceptDatatype {
  final String uuid;
  final String display;

  ConceptDatatype({
    required this.uuid,
    required this.display,
  });

  factory ConceptDatatype.fromJson(Map<String, dynamic> json) {
    return ConceptDatatype(
      uuid: json['uuid'] ?? '',
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'display': display,
    };
  }
}

class ConceptClass {
  final String uuid;
  final String display;

  ConceptClass({
    required this.uuid,
    required this.display,
  });

  factory ConceptClass.fromJson(Map<String, dynamic> json) {
    return ConceptClass(
      uuid: json['uuid'] ?? '',
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'display': display,
    };
  }
}

class ConceptMapping {
  final String? uuid;
  final String? conceptReferenceTerm;
  final String? conceptMapType;

  ConceptMapping({
    this.uuid,
    this.conceptReferenceTerm,
    this.conceptMapType,
  });

  factory ConceptMapping.fromJson(Map<String, dynamic> json) {
    return ConceptMapping(
      uuid: json['uuid'],
      conceptReferenceTerm: json['conceptReferenceTerm'],
      conceptMapType: json['conceptMapType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'conceptReferenceTerm': conceptReferenceTerm,
      'conceptMapType': conceptMapType,
    };
  }
}
