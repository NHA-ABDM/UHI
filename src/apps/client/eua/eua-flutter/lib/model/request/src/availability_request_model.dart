import 'package:uhi_flutter_app/model/model.dart';

class AvailabilityRequestModel {
  ContextModel? context;
  AvailabilityMessage? message;

  AvailabilityRequestModel({this.context, this.message});

  AvailabilityRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new AvailabilityMessage.fromJson(json['message'])
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

class AvailabilityMessage {
  AvailabilityIntent? intent;

  AvailabilityMessage({this.intent});

  AvailabilityMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? new AvailabilityIntent.fromJson(json['intent'])
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

class AvailabilityIntent {
  AvailabilityFulfillment? fulfillment;

  AvailabilityIntent({this.fulfillment});

  AvailabilityIntent.fromJson(Map<String, dynamic> json) {
    fulfillment = json['fulfillment'] != null
        ? new AvailabilityFulfillment.fromJson(json['fulfillment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment!.toJson();
    }
    return data;
  }
}

class AvailabilityFulfillment {
  AvailabilityStart? start;
  AvailabilityStart? end;

  AvailabilityFulfillment({this.start, this.end});

  AvailabilityFulfillment.fromJson(Map<String, dynamic> json) {
    start = json['start'] != null
        ? new AvailabilityStart.fromJson(json['start'])
        : null;
    end = json['end'] != null
        ? new AvailabilityStart.fromJson(json['end'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.start != null) {
      data['start'] = this.start!.toJson();
    }
    if (this.end != null) {
      data['end'] = this.end!.toJson();
    }
    return data;
  }
}

class AvailabilityStart {
  String? time;

  AvailabilityStart({this.time});

  AvailabilityStart.fromJson(Map<String, dynamic> json) {
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    return data;
  }
}
