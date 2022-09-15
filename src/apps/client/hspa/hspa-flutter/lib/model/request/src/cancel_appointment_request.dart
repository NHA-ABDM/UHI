

import '../../src/context_model.dart';

class CancelAppointmentRequestModel {
  ContextModel? context;
  CancelAppointmentRequestMessage? message;

  CancelAppointmentRequestModel({this.context, this.message});

  CancelAppointmentRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? CancelAppointmentRequestMessage.fromJson(json['message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    // ignore: prefer_collection_literals
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (context != null) {
      data['context'] = context!.toJson();
    }
    if (message != null) {
      data['message'] = message!.toJson();
    }
    return data;
  }
}

class CancelAppointmentRequestMessage {
  CancelAppointmentRequestOrder? order;

  CancelAppointmentRequestMessage({this.order});

  CancelAppointmentRequestMessage.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null
        ? CancelAppointmentRequestOrder.fromJson(json['order'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (order != null) {
      data['order'] = order!.toJson();
    }
    return data;
  }
}

class CancelAppointmentRequestOrder {
  String? id;
  String? state;
  CancelAppointmentRequestFulfillment? fulfillment;

  CancelAppointmentRequestOrder({this.id, this.state, this.fulfillment});

  CancelAppointmentRequestOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    state = json['state'];
    fulfillment = json['fulfillment'] != null
        ? CancelAppointmentRequestFulfillment.fromJson(json['fulfillment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['state'] = state;
    if (fulfillment != null) {
      data['fulfillment'] = fulfillment!.toJson();
    }
    return data;
  }
}

class CancelAppointmentRequestFulfillment {
  CancelAppointmentRequestTags? tags;

  CancelAppointmentRequestFulfillment({this.tags});

  CancelAppointmentRequestFulfillment.fromJson(Map<String, dynamic> json) {
    tags = json['tags'] != null
        ? CancelAppointmentRequestTags.fromJson(json['tags'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tags != null) {
      data['tags'] = tags!.toJson();
    }
    return data;
  }
}

/*class CancelAppointmentRequestTags {
  String? abdmGovInCancelledby;

  CancelAppointmentRequestTags({this.abdmGovInCancelledby});

  CancelAppointmentRequestTags.fromJson(Map<String, dynamic> json) {
    abdmGovInCancelledby = json['@abdm/gov.in/cancelledby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['@abdm/gov.in/cancelledby'] = abdmGovInCancelledby;
    return data;
  }
}*/


class CancelAppointmentRequestTags {
  Map<String, dynamic>? tagMap;

  CancelAppointmentRequestTags({this.tagMap});

  CancelAppointmentRequestTags.fromJson(Map<String, dynamic> jsonMap) {
    tagMap = <String, dynamic>{};
    tagMap?.addAll(jsonMap);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data.addAll(tagMap!);
    return data;
  }
}
