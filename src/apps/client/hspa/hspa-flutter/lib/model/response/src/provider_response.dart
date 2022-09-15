import 'package:flutter/material.dart';

class ProviderListResponse {
  List<Results>? results;

  ProviderListResponse({this.results});

  ProviderListResponse.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? uuid;
  String? display;
  Person? person;
  String? identifier;
  List<Attributes>? attributes;
  bool? retired;
  AuditInfo? auditInfo;
  List<Links>? links;
  String? resourceVersion;

  Results(
      {this.uuid,
        this.display,
        this.person,
        this.identifier,
        this.attributes,
        this.retired,
        this.auditInfo,
        this.links,
        this.resourceVersion});

  Results.fromJson(Map<String, dynamic> json) {
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
    resourceVersion = json['resourceVersion'];
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
  TimeOfDay? birthTime;
  bool? deathDateEstimated;
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
        this.birthTime,
        this.deathDateEstimated,
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
   /* if (json['attributes'] != null) {
      attributes = <Null>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Null.fromJson(v));
      });
    }*/
    voided = json['voided'];
    birthTime = json['birthtime'];
    deathDateEstimated = json['deathdateEstimated'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'];
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
   /* if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }*/
    data['voided'] = voided;
    data['birthtime'] = birthTime;
    data['deathdateEstimated'] = deathDateEstimated;
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
    value = json['value'].toString();
    voided = json['voided'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    resourceVersion = json['resourceVersion'];
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

class AuditInfo {
  PreferredName? creator;
  String? dateCreated;
  ChangedBy? changedBy;
  String? dateChanged;

  AuditInfo({this.creator, this.dateCreated, this.changedBy, this.dateChanged});

  AuditInfo.fromJson(Map<String, dynamic> json) {
    creator = json['creator'] != null
        ? PreferredName.fromJson(json['creator'])
        : null;
    dateCreated = json['dateCreated'];
    changedBy = json['changedBy'] != null ? ChangedBy.fromJson(json['changedBy']) : null;
    dateChanged = json['dateChanged'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    data['dateCreated'] = dateCreated;
    data['changedBy'] = changedBy;
    data['dateChanged'] = dateChanged;
    return data;
  }
}

class ChangedBy {
  String? uuid;
  String? display;
  List<Links>? links;

  ChangedBy({this.uuid, this.display, this.links});

  ChangedBy.fromJson(Map<String, dynamic> json) {
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
