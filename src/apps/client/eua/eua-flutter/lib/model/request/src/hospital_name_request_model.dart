import 'package:uhi_flutter_app/model/model.dart';

class HospitalNameRequestModel {
  ContextModel? context;
  HospitalNameMessage? message;

  HospitalNameRequestModel({this.context, this.message});

  HospitalNameRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new HospitalNameMessage.fromJson(json['message'])
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

class HospitalNameMessage {
  HospitalNameIntent? intent;

  HospitalNameMessage({this.intent});

  HospitalNameMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? new HospitalNameIntent.fromJson(json['intent'])
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

class HospitalNameIntent {
  HospitalNameProvider? provider;

  HospitalNameIntent({this.provider});

  HospitalNameIntent.fromJson(Map<String, dynamic> json) {
    provider = json['provider'] != null
        ? new HospitalNameProvider.fromJson(json['provider'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.provider != null) {
      data['provider'] = this.provider!.toJson();
    }
    return data;
  }
}

class HospitalNameProvider {
  HospitalNameDescriptor? descriptor;

  HospitalNameProvider({this.descriptor});

  HospitalNameProvider.fromJson(Map<String, dynamic> json) {
    descriptor = json['descriptor'] != null
        ? new HospitalNameDescriptor.fromJson(json['descriptor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.descriptor != null) {
      data['descriptor'] = this.descriptor!.toJson();
    }
    return data;
  }
}

class HospitalNameDescriptor {
  String? name;

  HospitalNameDescriptor({this.name});

  HospitalNameDescriptor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
