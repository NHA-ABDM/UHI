import 'package:flutter/material.dart';

class AddProviderAttributeResponse {
  String? display;
  String? uuid;
  AttributeType? attributeType;
  String? value;
  bool? voided;
  List<Links>? links;
  String? resourceVersion;

  AddProviderAttributeResponse(
      {this.display,
        this.uuid,
        this.attributeType,
        this.value,
        this.voided,
        this.links,
        this.resourceVersion});

  AddProviderAttributeResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('Json is $json');
    display = json['display'];
    uuid = json['uuid'];
    attributeType = json['attributeType'] != null
        ? AttributeType.fromJson(json['attributeType'])
        : null;
    value = json['value'].toString();
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

class AttributeType {
  String? uuid;
  String? display;
  List<Links>? links;

  AttributeType({this.uuid, this.display, this.links});

  AttributeType.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'].toString();
    display = json['display'].toString();
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
    rel = json['rel'].toString();
    uri = json['uri'].toString();
    resourceAlias = json['resourceAlias'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rel'] = rel;
    data['uri'] = uri;
    data['resourceAlias'] = resourceAlias;
    return data;
  }
}
