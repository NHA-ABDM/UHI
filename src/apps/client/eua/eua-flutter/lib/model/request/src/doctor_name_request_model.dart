import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';

class DoctorNameRequestModel {
  ContextModel? context;
  DoctorNameMessage? message;

  DoctorNameRequestModel({this.context, this.message});

  DoctorNameRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new DoctorNameMessage.fromJson(json['message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.context != null) {
      data['context'] = this.context!.toJson();
    }
    if (this.message != null) {
      data['message'] = this.message!.toJson();
    }
    return data;
  }
}

class DoctorNameMessage {
  DoctorNameIntent? intent;

  DoctorNameMessage({this.intent});

  DoctorNameMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? new DoctorNameIntent.fromJson(json['intent'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.intent != null) {
      data['intent'] = this.intent!.toJson();
    }
    return data;
  }
}

class DoctorNameIntent {
  DoctorNameFulfillment? fulfillment;
  DiscoveryProviders? provider;

  DoctorNameIntent({this.fulfillment, this.provider});

  DoctorNameIntent.fromJson(Map<String, dynamic> json) {
    fulfillment = json['fulfillment'] != null
        ? new DoctorNameFulfillment.fromJson(json['fulfillment'])
        : null;

    provider = json['provider'] != null
        ? new DiscoveryProviders.fromJson(json['provider'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment;
    }
    if (this.provider != null) {
      data['provider'] = this.provider;
    }
    return data;
  }
}

class Descriptor {
  //String? code;
  String? name;

  Descriptor({this.name});

  Descriptor.fromJson(Map<String, dynamic> json) {
    // if (json['code'] != null) {
    //   code = json['code'];
    // }
    if (json['name'] != null) {
      name = json['name'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    // if (this.code != null) {
    //   data['code'] = this.code;
    // }
    if (this.name != null) {
      data['name'] = this.name;
    }

    return data;
  }
}

class DoctorNameFulfillment {
  DoctorNameAgent? agent;
  Start? startTime;
  Start? endTime;
  String? type;

  DoctorNameFulfillment({this.agent, this.startTime, this.endTime, this.type});

  DoctorNameFulfillment.fromJson(Map<String, dynamic> json) {
    agent = json['agent'] != null
        ? new DoctorNameAgent.fromJson(json['agent'])
        : null;

    startTime =
        json['start'] != null ? new Start.fromJson(json['start']) : null;
    endTime = json['end'] != null ? new Start.fromJson(json['end']) : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.agent != null) {
      data['agent'] = this.agent;
    }
    if (this.startTime != null) {
      data['start'] = this.startTime;
    }
    if (this.endTime != null) {
      data['end'] = this.endTime;
    }
    data['type'] = this.type;

    return data;
  }
}

class DoctorNameAgent {
  String? name;
  String? id;
  String? cred;
  Tags? tags;

  DoctorNameAgent({this.name, this.id, this.cred, this.tags});

  DoctorNameAgent.fromJson(Map<String, dynamic> json) {
    if (json['name'] != null) {
      name = json['name'];
    }
    if (json['cred'] != null) {
      cred = json['cred'];
    }
    if (json['id'] != null) {
      id = json['id'];
    }
    if (json['tags'] != null) {
      tags = json['tags'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.name != null) {
      data['name'] = this.name;
    }
    if (this.cred != null) {
      data['cred'] = this.cred;
    }
    if (this.id != null) {
      data['id'] = this.id;
    }
    if (this.tags != null) {
      data['tags'] = this.tags;
    }

    return data;
  }
}
