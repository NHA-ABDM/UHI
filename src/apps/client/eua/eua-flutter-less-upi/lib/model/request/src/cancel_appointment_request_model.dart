import 'package:uhi_flutter_app/model/common/common.dart';

class CancelAppointmentRequestModel {
  ContextModel? context;
  CancelAppointmentRequestMessage? message;

  CancelAppointmentRequestModel({this.context, this.message});

  CancelAppointmentRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new CancelAppointmentRequestMessage.fromJson(json['message'])
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

class CancelAppointmentRequestMessage {
  CancelAppointmentRequestOrder? order;

  CancelAppointmentRequestMessage({this.order});

  CancelAppointmentRequestMessage.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null
        ? new CancelAppointmentRequestOrder.fromJson(json['order'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.order != null) {
      data['order'] = this.order!.toJson();
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
        ? new CancelAppointmentRequestFulfillment.fromJson(json['fulfillment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['state'] = this.state;
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment!.toJson();
    }
    return data;
  }
}

class CancelAppointmentRequestFulfillment {
  CancelAppointmentRequestTags? tags;

  CancelAppointmentRequestFulfillment({this.tags});

  CancelAppointmentRequestFulfillment.fromJson(Map<String, dynamic> json) {
    tags = json['tags'] != null
        ? new CancelAppointmentRequestTags.fromJson(json['tags'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tags != null) {
      data['tags'] = this.tags!.toJson();
    }
    return data;
  }
}

class CancelAppointmentRequestTags {
  String? abdmGovInCancelledby;

  CancelAppointmentRequestTags({this.abdmGovInCancelledby});

  CancelAppointmentRequestTags.fromJson(Map<String, dynamic> json) {
    abdmGovInCancelledby = json['@abdm/gov.in/cancelledby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@abdm/gov.in/cancelledby'] = this.abdmGovInCancelledby;
    return data;
  }
}
