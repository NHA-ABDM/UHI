class AppointmentSlots {
  List<ProviderAppointmentSlots>? providerAppointmentSlots;
  List<Links>? links;

  AppointmentSlots({this.providerAppointmentSlots, this.links});

  AppointmentSlots.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      providerAppointmentSlots = <ProviderAppointmentSlots>[];
      json['results'].forEach((v) {
        providerAppointmentSlots!.add(ProviderAppointmentSlots.fromJson(v));
      });
    }
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (providerAppointmentSlots != null) {
      data['results'] = providerAppointmentSlots!.map((v) => v.toJson()).toList();
    }
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProviderAppointmentSlots {
  String? uuid;
  String? display;
  String? startDate;
  String? endDate;
  //AppointmentBlock? appointmentBlock;
  int? countOfAppointments;
  int? unallocatedMinutes;
  bool? voided;
  //AuditInfo? auditInfo;
  //List<Links>? links;
  String? resourceVersion;

  ProviderAppointmentSlots(
      {this.uuid,
        this.display,
        this.startDate,
        this.endDate,
        //this.appointmentBlock,
        this.countOfAppointments,
        this.unallocatedMinutes,
        this.voided,
        //this.auditInfo,
        //this.links,
        this.resourceVersion});

  ProviderAppointmentSlots.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    /*appointmentBlock = json['appointmentBlock'] != null
        ? AppointmentBlock.fromJson(json['appointmentBlock'])
        : null;*/
    countOfAppointments = json['countOfAppointments'];
    unallocatedMinutes = json['unallocatedMinutes'];
    voided = json['voided'];
    /*auditInfo = json['auditInfo'] != null
        ? AuditInfo.fromJson(json['auditInfo'])
        : null;*/
    /*if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }*/
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    /*if (appointmentBlock != null) {
      data['appointmentBlock'] = appointmentBlock!.toJson();
    }*/
    data['countOfAppointments'] = countOfAppointments;
    data['unallocatedMinutes'] = unallocatedMinutes;
    data['voided'] = voided;
    /*if (auditInfo != null) {
      data['auditInfo'] = auditInfo!.toJson();
    }*/
    /*if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }*/
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class AppointmentBlock {
  String? uuid;
  String? display;
  String? startDate;
  String? endDate;
  Provider? provider;
  Location? location;
  List<Types>? types;
  bool? voided;
  AuditInfo? auditInfo;
  List<Links>? links;
  String? resourceVersion;

  AppointmentBlock(
      {this.uuid,
        this.display,
        this.startDate,
        this.endDate,
        this.provider,
        this.location,
        this.types,
        this.voided,
        this.auditInfo,
        this.links,
        this.resourceVersion});

  AppointmentBlock.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    provider = json['provider'] != null
        ? Provider.fromJson(json['provider'])
        : null;
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    if (json['types'] != null) {
      types = <Types>[];
      json['types'].forEach((v) {
        types!.add(Types.fromJson(v));
      });
    }
    voided = json['voided'];
    auditInfo = json['auditInfo'] != null
        ? AuditInfo.fromJson(json['auditInfo'])
        : null;
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (types != null) {
      data['types'] = types!.map((v) => v.toJson()).toList();
    }
    data['voided'] = voided;
    if (auditInfo != null) {
      data['auditInfo'] = auditInfo!.toJson();
    }
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class Provider {
  String? uuid;
  String? display;
  Person? person;
  String? identifier;
  List<Attributes>? attributes;
  bool? retired;
  AuditInfo? auditInfo;
  List<Links>? links;
  String? resourceVersion;

  Provider(
      {this.uuid,
        this.display,
        this.person,
        this.identifier,
        this.attributes,
        this.retired,
        this.auditInfo,
        this.links,
        this.resourceVersion});

  Provider.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    person =
    json['person'] != null ? Person.fromJson(json['person']) : null;
    identifier = json['identifier'];
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
    retired = json['retired'];
    auditInfo = json['auditInfo'] != null
        ? AuditInfo.fromJson(json['auditInfo'])
        : null;
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    if (person != null) {
      data['person'] = person!.toJson();
    }
    data['identifier'] = identifier;
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    data['retired'] = retired;
    if (auditInfo != null) {
      data['auditInfo'] = auditInfo!.toJson();
    }
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class Person {
  String? uuid;
  String? display;
  String? gender;
  int? age;
  String? birthdate;
  bool? birthdateEstimated;
  bool? dead;
  DateTime? deathDate;
  String? causeOfDeath;
  PreferredName? preferredName;
  String? preferredAddress;
  //List<Null>? attributes;
  bool? voided;
  String? birthtime;
  bool? deathdateEstimated;
  List<Links>? links;
  String? resourceVersion;

  Person(
      {this.uuid,
        this.display,
        this.gender,
        this.age,
        this.birthdate,
        this.birthdateEstimated,
        this.dead,
        this.deathDate,
        this.causeOfDeath,
        this.preferredName,
        this.preferredAddress,
        //this.attributes,
        this.voided,
        this.birthtime,
        this.deathdateEstimated,
        this.links,
        this.resourceVersion});

  Person.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    gender = json['gender'];
    age = json['age'];
    birthdate = json['birthdate'];
    birthdateEstimated = json['birthdateEstimated'];
    dead = json['dead'];
    deathDate = json['deathDate'];
    causeOfDeath = json['causeOfDeath'];
    preferredName = json['preferredName'] != null
        ? PreferredName.fromJson(json['preferredName'])
        : null;
    preferredAddress = json['preferredAddress'];
    /*if (json['attributes'] != null) {
      attributes = <Null>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Null.fromJson(v));
      });
    }*/
    voided = json['voided'];
    birthtime = json['birthtime'];
    deathdateEstimated = json['deathdateEstimated'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    data['gender'] = gender;
    data['age'] = age;
    data['birthdate'] = birthdate;
    data['birthdateEstimated'] = birthdateEstimated;
    data['dead'] = dead;
    data['deathDate'] = deathDate;
    data['causeOfDeath'] = causeOfDeath;
    if (preferredName != null) {
      data['preferredName'] = preferredName!.toJson();
    }
    data['preferredAddress'] = preferredAddress;
    /*if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }*/
    data['voided'] = voided;
    data['birthtime'] = birthtime;
    data['deathdateEstimated'] = deathdateEstimated;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class PreferredName {
  String? uuid;
  String? display;
  List<Links>? links;

  PreferredName({this.uuid, this.display, this.links});

  PreferredName.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Links {
  String? rel;
  String? uri;
  String? resourceAlias;

  Links({this.rel, this.uri, this.resourceAlias});

  Links.fromJson(Map<String, dynamic> json) {
    rel = json['rel'];
    uri = json['uri'];
    resourceAlias = json['resourceAlias'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rel'] = rel;
    data['uri'] = uri;
    data['resourceAlias'] = resourceAlias;
    return data;
  }
}

class Attributes {
  String? display;
  String? uuid;
  PreferredName? attributeType;
  String? value;
  bool? voided;
  List<Links>? links;
  String? resourceVersion;

  Attributes(
      {this.display,
        this.uuid,
        this.attributeType,
        this.value,
        this.voided,
        this.links,
        this.resourceVersion});

  Attributes.fromJson(Map<String, dynamic> json) {
    display = json['display'];
    uuid = json['uuid'];
    attributeType = json['attributeType'] != null
        ? PreferredName.fromJson(json['attributeType'])
        : null;
    value = json['value'];
    voided = json['voided'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['display'] = display;
    data['uuid'] = uuid;
    if (attributeType != null) {
      data['attributeType'] = attributeType!.toJson();
    }
    data['value'] = value;
    data['voided'] = voided;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

/*class AuditInfo {
  PreferredName? creator;
  String? dateCreated;
  Null? changedBy;
  Null? dateChanged;

  AuditInfo({this.creator, this.dateCreated, this.changedBy, this.dateChanged});

  AuditInfo.fromJson(Map<String, dynamic> json) {
    creator = json['creator'] != null
        ? new PreferredName.fromJson(json['creator'])
        : null;
    dateCreated = json['dateCreated'];
    changedBy = json['changedBy'];
    dateChanged = json['dateChanged'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.creator != null) {
      data['creator'] = this.creator!.toJson();
    }
    data['dateCreated'] = this.dateCreated;
    data['changedBy'] = this.changedBy;
    data['dateChanged'] = this.dateChanged;
    return data;
  }
}*/

class Location {
  String? uuid;
  String? display;
  String? name;
  String? description;
  String? address1;
  String? address2;
  String? cityVillage;
  String? stateProvince;
  String? country;
  String? postalCode;
  String? latitude;
  String? longitude;
  String? countyDistrict;
  String? address3;
  String? address4;
  String? address5;
  String? address6;
  List<Tags>? tags;
  ParentLocation? parentLocation;
  //List<Null>? childLocations;
  bool? retired;
  AuditInfo? auditInfo;
  //List<Null>? attributes;
  String? address7;
  String? address8;
  String? address9;
  String? address10;
  String? address11;
  String? address12;
  String? address13;
  String? address14;
  String? address15;
  List<Links>? links;
  String? resourceVersion;

  Location(
      {this.uuid,
        this.display,
        this.name,
        this.description,
        this.address1,
        this.address2,
        this.cityVillage,
        this.stateProvince,
        this.country,
        this.postalCode,
        this.latitude,
        this.longitude,
        this.countyDistrict,
        this.address3,
        this.address4,
        this.address5,
        this.address6,
        this.tags,
        this.parentLocation,
        //this.childLocations,
        this.retired,
        this.auditInfo,
        //this.attributes,
        this.address7,
        this.address8,
        this.address9,
        this.address10,
        this.address11,
        this.address12,
        this.address13,
        this.address14,
        this.address15,
        this.links,
        this.resourceVersion});

  Location.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    name = json['name'];
    description = json['description'];
    address1 = json['address1'];
    address2 = json['address2'];
    cityVillage = json['cityVillage'];
    stateProvince = json['stateProvince'];
    country = json['country'];
    postalCode = json['postalCode'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    countyDistrict = json['countyDistrict'].toString();
    address3 = json['address3'];
    address4 = json['address4'];
    address5 = json['address5'];
    address6 = json['address6'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(Tags.fromJson(v));
      });
    }
    parentLocation = json['parentLocation'] != null
        ? ParentLocation.fromJson(json['parentLocation'])
        : null;
    /*if (json['childLocations'] != null) {
      childLocations = <Null>[];
      json['childLocations'].forEach((v) {
        childLocations!.add(new Null.fromJson(v));
      });
    }*/
    retired = json['retired'];
    auditInfo = json['auditInfo'] != null
        ? AuditInfo.fromJson(json['auditInfo'])
        : null;
    /*if (json['attributes'] != null) {
      attributes = <Null>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Null.fromJson(v));
      });
    }*/
    address7 = json['address7'];
    address8 = json['address8'];
    address9 = json['address9'];
    address10 = json['address10'];
    address11 = json['address11'];
    address12 = json['address12'];
    address13 = json['address13'];
    address14 = json['address14'];
    address15 = json['address15'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    data['name'] = name;
    data['description'] = description;
    data['address1'] = address1;
    data['address2'] = address2;
    data['cityVillage'] = cityVillage;
    data['stateProvince'] = stateProvince;
    data['country'] = country;
    data['postalCode'] = postalCode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['countyDistrict'] = countyDistrict;
    data['address3'] = address3;
    data['address4'] = address4;
    data['address5'] = address5;
    data['address6'] = address6;
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    if (parentLocation != null) {
      data['parentLocation'] = parentLocation!.toJson();
    }
   /* if (this.childLocations != null) {
      data['childLocations'] =
          this.childLocations!.map((v) => v.toJson()).toList();
    }*/
    data['retired'] = retired;
    if (auditInfo != null) {
      data['auditInfo'] = auditInfo!.toJson();
    }
    /*if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }*/
    data['address7'] = address7;
    data['address8'] = address8;
    data['address9'] = address9;
    data['address10'] = address10;
    data['address11'] = address11;
    data['address12'] = address12;
    data['address13'] = address13;
    data['address14'] = address14;
    data['address15'] = address15;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class Tags {
  String? uuid;
  String? display;
  String? name;
  String? description;
  bool? retired;
  List<Links>? links;
  String? resourceVersion;

  Tags(
      {this.uuid,
        this.display,
        this.name,
        this.description,
        this.retired,
        this.links,
        this.resourceVersion});

  Tags.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    name = json['name'];
    description = json['description'];
    retired = json['retired'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    data['name'] = name;
    data['description'] = description;
    data['retired'] = retired;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class ParentLocation {
  String? uuid;
  String? display;
  String? name;
  String? description;
  String? address1;
  String? address2;
  String? cityVillage;
  String? stateProvince;
  String? country;
  String? postalCode;
  String? latitude;
  String? longitude;
  String? countyDistrict;
  String? address3;
  String? address4;
  String? address5;
  String? address6;
  List<Tags>? tags;
  String? parentLocation;
  //List<ChildLocations>? childLocations;
  bool? retired;
  //List<Null>? attributes;
  String? address7;
  String? address8;
  String? address9;
  String? address10;
  String? address11;
  String? address12;
  String? address13;
  String? address14;
  String? address15;
  List<Links>? links;
  String? resourceVersion;

  ParentLocation(
      {this.uuid,
        this.display,
        this.name,
        this.description,
        this.address1,
        this.address2,
        this.cityVillage,
        this.stateProvince,
        this.country,
        this.postalCode,
        this.latitude,
        this.longitude,
        this.countyDistrict,
        this.address3,
        this.address4,
        this.address5,
        this.address6,
        this.tags,
        this.parentLocation,
        //this.childLocations,
        this.retired,
        //this.attributes,
        this.address7,
        this.address8,
        this.address9,
        this.address10,
        this.address11,
        this.address12,
        this.address13,
        this.address14,
        this.address15,
        this.links,
        this.resourceVersion});

  ParentLocation.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    name = json['name'];
    description = json['description'];
    address1 = json['address1'];
    address2 = json['address2'];
    cityVillage = json['cityVillage'];
    stateProvince = json['stateProvince'];
    country = json['country'];
    postalCode = json['postalCode'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    countyDistrict = json['countyDistrict'].toString();
    address3 = json['address3'];
    address4 = json['address4'];
    address5 = json['address5'];
    address6 = json['address6'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(Tags.fromJson(v));
      });
    }
    parentLocation = json['parentLocation'];
    /*if (json['childLocations'] != null) {
      childLocations = <ChildLocations>[];
      json['childLocations'].forEach((v) {
        childLocations!.add(new ChildLocations.fromJson(v));
      });
    }*/
    retired = json['retired'];
    /*if (json['attributes'] != null) {
      attributes = <Null>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Null.fromJson(v));
      });
    }*/
    address7 = json['address7'];
    address8 = json['address8'];
    address9 = json['address9'];
    address10 = json['address10'];
    address11 = json['address11'];
    address12 = json['address12'];
    address13 = json['address13'];
    address14 = json['address14'];
    address15 = json['address15'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    data['name'] = name;
    data['description'] = description;
    data['address1'] = address1;
    data['address2'] = address2;
    data['cityVillage'] = cityVillage;
    data['stateProvince'] = stateProvince;
    data['country'] = country;
    data['postalCode'] = postalCode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['countyDistrict'] = countyDistrict;
    data['address3'] = address3;
    data['address4'] = address4;
    data['address5'] = address5;
    data['address6'] = address6;
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    data['parentLocation'] = parentLocation;
    /*if (this.childLocations != null) {
      data['childLocations'] =
          this.childLocations!.map((v) => v.toJson()).toList();
    }*/
    data['retired'] = retired;
    /*if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }*/
    data['address7'] = address7;
    data['address8'] = address8;
    data['address9'] = address9;
    data['address10'] = address10;
    data['address11'] = address11;
    data['address12'] = address12;
    data['address13'] = address13;
    data['address14'] = address14;
    data['address15'] = address15;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class AuditInfo {
  PreferredName? creator;
  String? dateCreated;
  String? changedBy;
  String? dateChanged;

  AuditInfo({this.creator, this.dateCreated, this.changedBy, this.dateChanged});

  AuditInfo.fromJson(Map<String, dynamic> json) {
    creator = json['creator'] != null
        ? PreferredName.fromJson(json['creator'])
        : null;
    dateCreated = json['dateCreated'];
    changedBy = json['changedBy'];
    dateChanged = json['dateChanged'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    data['dateCreated'] = dateCreated;
    if (changedBy != null) {
      data['changedBy'] = changedBy;
    }
    data['dateChanged'] = dateChanged;
    return data;
  }
}

class Types {
  String? uuid;
  String? display;
  String? name;
  String? description;
  int? duration;
  bool? confidential;
  String? visitType;
  bool? retired;
  AuditInfo? auditInfo;
  List<Links>? links;
  String? resourceVersion;

  Types(
      {this.uuid,
        this.display,
        this.name,
        this.description,
        this.duration,
        this.confidential,
        this.visitType,
        this.retired,
        this.auditInfo,
        this.links,
        this.resourceVersion});

  Types.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    name = json['name'];
    description = json['description'];
    duration = json['duration'];
    confidential = json['confidential'];
    visitType = json['visitType'];
    retired = json['retired'];
    auditInfo = json['auditInfo'] != null
        ? AuditInfo.fromJson(json['auditInfo'])
        : null;
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['display'] = display;
    data['name'] = name;
    data['description'] = description;
    data['duration'] = duration;
    data['confidential'] = confidential;
    data['visitType'] = visitType;
    data['retired'] = retired;
    if (auditInfo != null) {
      data['auditInfo'] = auditInfo!.toJson();
    }
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

/*class Links {
  String? rel;
  String? uri;
  Null? resourceAlias;

  Links({this.rel, this.uri, this.resourceAlias});

  Links.fromJson(Map<String, dynamic> json) {
    rel = json['rel'];
    uri = json['uri'];
    resourceAlias = json['resourceAlias'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rel'] = this.rel;
    data['uri'] = this.uri;
    data['resourceAlias'] = this.resourceAlias;
    return data;
  }
}*/
