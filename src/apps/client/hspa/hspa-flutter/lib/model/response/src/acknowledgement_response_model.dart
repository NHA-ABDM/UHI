
import '../../src/context_model.dart';

class AcknowledgementResponseModel {
  ContextModel? context;
  AcknowledgementMessage? message;

  AcknowledgementResponseModel({this.context, this.message});

  AcknowledgementResponseModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? AcknowledgementMessage.fromJson(json['message'])
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

class AcknowledgementMessage {
  AcknowledgementAck? ack;

  AcknowledgementMessage({this.ack});

  AcknowledgementMessage.fromJson(Map<String, dynamic> json) {
    ack = json['ack'] != null
        ? new AcknowledgementAck.fromJson(json['ack'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ack != null) {
      data['ack'] = this.ack!.toJson();
    }
    return data;
  }
}

class AcknowledgementAck {
  String? status;

  AcknowledgementAck({this.status});

  AcknowledgementAck.fromJson(Map<String, dynamic> json) {
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    return data;
  }
}
