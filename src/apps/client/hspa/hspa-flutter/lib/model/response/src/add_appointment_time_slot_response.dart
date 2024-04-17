class AddAppointmentTimeSlotResponse {
  String? uuid;
  String? display;
  String? startDate;
  String? endDate;
  Provider? provider;
  Person? location;
  List<Types>? types;
  bool? voided;
  List<Links>? links;
  String? resourceVersion;

  AddAppointmentTimeSlotResponse(
      {this.uuid,
        this.display,
        this.startDate,
        this.endDate,
        this.provider,
        this.location,
        this.types,
        this.voided,
        this.links,
        this.resourceVersion});

  AddAppointmentTimeSlotResponse.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    display = json['display'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    provider = json['provider'] != null
        ? Provider.fromJson(json['provider'])
        : null;
    location =
    json['location'] != null ? Person.fromJson(json['location']) : null;
    if (json['types'] != null) {
      types = <Types>[];
      json['types'].forEach((v) {
        types!.add(Types.fromJson(v));
      });
    }
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
  List<Links>? links;
  String? resourceVersion;

  Provider(
      {this.uuid,
        this.display,
        this.person,
        this.identifier,
        this.attributes,
        this.retired,
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
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['resourceVersion'] = resourceVersion;
    return data;
  }
}

class Attributes {
  String? uuid;
  String? display;
  List<Links>? links;

  Attributes({this.uuid, this.display, this.links});

  Attributes.fromJson(Map<String, dynamic> json) {
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

class Person {
  String? uuid;
  String? display;
  List<Links>? links;

  Person({this.uuid, this.display, this.links});

  Person.fromJson(Map<String, dynamic> json) {
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

class Location {
  String? uuid;
  String? display;
  List<Links>? links;

  Location({this.uuid, this.display, this.links});

  Location.fromJson(Map<String, dynamic> json) {
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

class Types {
  String? uuid;
  String? display;
  List<Links>? links;

  Types({this.uuid, this.display, this.links});

  Types.fromJson(Map<String, dynamic> json) {
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
