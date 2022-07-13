import 'package:uhi_flutter_app/model/model.dart';

class MultiParamsRequestModel {
  ContextModel? context;
  MultiParamsMessage? message;

  MultiParamsRequestModel({this.context, this.message});

  MultiParamsRequestModel.fromJson(Map<String, dynamic> json) {
    context =
        json['context'] != null ? ContextModel.fromJson(json['context']) : null;
    message = json['message'] != null
        ? MultiParamsMessage.fromJson(json['message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.context != null) {
      data['context'] = this.context!.toJson();
    }
    if (this.message != null) {
      data['message'] = this.message!.toJson();
    }
    return data;
  }
}

class MultiParamsMessage {
  MultiParamsIntent? intent;

  MultiParamsMessage({this.intent});

  MultiParamsMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? MultiParamsIntent.fromJson(json['intent'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.intent != null) {
      data['intent'] = this.intent!.toJson();
    }
    return data;
  }
}

class MultiParamsIntent {
  MultiParamsCategory? category;
  MultiParamsCategory? provider;
  MultiParamsFulfillment? fulfillment;

  MultiParamsIntent({this.category, this.provider, this.fulfillment});

  MultiParamsIntent.fromJson(Map<String, dynamic> json) {
    category = json['category'] != null
        ? MultiParamsCategory.fromJson(json['category'])
        : null;
    provider = json['provider'] != null
        ? MultiParamsCategory.fromJson(json['provider'])
        : null;
    fulfillment = json['fulfillment'] != null
        ? MultiParamsFulfillment.fromJson(json['fulfillment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.provider != null) {
      data['provider'] = this.provider!.toJson();
    }
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment!.toJson();
    }
    return data;
  }
}

class MultiParamsCategory {
  MultiParamsDescriptor? descriptor;

  MultiParamsCategory({this.descriptor});

  MultiParamsCategory.fromJson(Map<String, dynamic> json) {
    descriptor = json['descriptor'] != null
        ? MultiParamsDescriptor.fromJson(json['descriptor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.descriptor != null) {
      data['descriptor'] = this.descriptor!.toJson();
    }
    return data;
  }
}

class MultiParamsDescriptor {
  String? name;

  MultiParamsDescriptor({this.name});

  MultiParamsDescriptor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}

class MultiParamsFulfillment {
  String? type;

  MultiParamsFulfillment({this.type});

  MultiParamsFulfillment.fromJson(Map<String, dynamic> json) {
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['type'] = this.type;
    return data;
  }
}
