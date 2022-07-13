import 'package:uhi_flutter_app/model/model.dart';

class DoctorNameWithAvailabilityRequestModel {
  ContextModel? context;
  DoctorNameWithAvailabilityMessage? message;

  DoctorNameWithAvailabilityRequestModel({this.context, this.message});

  DoctorNameWithAvailabilityRequestModel.fromJson(Map<String, dynamic> json) {
    context =
        json['context'] != null ? ContextModel.fromJson(json['context']) : null;
    message = json['message'] != null
        ? DoctorNameWithAvailabilityMessage.fromJson(json['message'])
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

class DoctorNameWithAvailabilityMessage {
  DoctorNameWithAvailabilityIntent? intent;

  DoctorNameWithAvailabilityMessage({this.intent});

  DoctorNameWithAvailabilityMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? DoctorNameWithAvailabilityIntent.fromJson(json['intent'])
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

class DoctorNameWithAvailabilityIntent {
  DoctorNameWithAvailabilityFulfillment? fulfillment;

  DoctorNameWithAvailabilityIntent({this.fulfillment});

  DoctorNameWithAvailabilityIntent.fromJson(Map<String, dynamic> json) {
    fulfillment = json['fulfillment'] != null
        ? DoctorNameWithAvailabilityFulfillment.fromJson(json['fulfillment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment!.toJson();
    }
    return data;
  }
}

class DoctorNameWithAvailabilityFulfillment {
  DoctorNameAgent? agent;
  AvailabilityStart? start;
  AvailabilityStart? end;

  DoctorNameWithAvailabilityFulfillment({this.agent, this.start, this.end});

  DoctorNameWithAvailabilityFulfillment.fromJson(Map<String, dynamic> json) {
    agent =
        json['agent'] != null ? DoctorNameAgent.fromJson(json['agent']) : null;
    start = json['start'] != null
        ? AvailabilityStart.fromJson(json['start'])
        : null;
    end = json['end'] != null ? AvailabilityStart.fromJson(json['end']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.agent != null) {
      data['agent'] = this.agent!.toJson();
    }
    if (this.start != null) {
      data['start'] = this.start!.toJson();
    }
    if (this.end != null) {
      data['end'] = this.end!.toJson();
    }
    return data;
  }
}
