
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
    final Map<String, dynamic> data = <String, dynamic>{};
    if (context != null) {
      data['context'] = context!.toJson();
    }
    if (message != null) {
      data['message'] = message!.toJson();
    }
    return data;
  }
}

class AcknowledgementMessage {
  AcknowledgementAck? ack;

  AcknowledgementMessage({this.ack});

  AcknowledgementMessage.fromJson(Map<String, dynamic> json) {
    ack = json['ack'] != null
        ? AcknowledgementAck.fromJson(json['ack'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ack != null) {
      data['ack'] = ack!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    return data;
  }
}
