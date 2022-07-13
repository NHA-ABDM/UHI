class HPIDBadRequest {
  String? code;
  String? message;
  List<Details>? details;

  HPIDBadRequest({this.code, this.message, this.details});

  HPIDBadRequest.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    if (json['details'] != null) {
      details = <Details>[];
      json['details'].forEach((v) {
        details!.add(Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Details {
  String? message;
  String? code;
  Attribute? attribute;

  Details({this.message, this.code, this.attribute});

  Details.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    code = json['code'];
    attribute = json['attribute'] != null
        ? Attribute.fromJson(json['attribute'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['code'] = code;
    if (attribute != null) {
      data['attribute'] = attribute!.toJson();
    }
    return data;
  }
}

class Attribute {
  String? key;
  String? value;

  Attribute({this.key, this.value});

  Attribute.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}
