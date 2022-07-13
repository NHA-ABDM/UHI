class ProviderRequest {

}

class Provider {
  String? name;
  Person? person;
  String? identifier;
  List<Attributes>? attributes;
  bool? retired;

  Provider(
      {required this.name, required this.person, required this.identifier, required this.attributes, this.retired = false});

  Provider.fromJson(Map<String, dynamic> json) {
    name = json['name'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (person != null) {
      data['person'] = person!.toJson();
    }
    data['identifier'] = identifier;
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    data['retired'] = retired;
    return data;
  }
}

class Person {
  String? gender;
  int? age;
  List<Names>? names;

  Person({this.gender, this.age, this.names});

  Person.fromJson(Map<String, dynamic> json) {
    gender = json['gender'];
    age = json['age'];
    if (json['names'] != null) {
      names = <Names>[];
      json['names'].forEach((v) {
        names!.add(Names.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gender'] = gender;
    data['age'] = age;
    if (names != null) {
      data['names'] = names!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Names {
  late String givenName;
  late String familyName;

  Names({required this.givenName, required this.familyName});

  Names.fromJson(Map<String, dynamic> json) {
    givenName = json['givenName'];
    familyName = json['familyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['givenName'] = givenName;
    data['familyName'] = familyName;
    return data;
  }
}

class Attributes {
  late String attributeType;
  late String value;

  Attributes({required this.attributeType, required this.value});

  Attributes.fromJson(Map<String, dynamic> json) {
    attributeType = json['attributeType'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attributeType'] = attributeType;
    data['value'] = value;
    return data;
  }
}