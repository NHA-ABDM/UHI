import 'package:uhi_flutter_app/model/model.dart';

class SpokenLanguagesRequestModel {
  ContextModel? context;
  SpokenLanguagesMessage? message;

  SpokenLanguagesRequestModel({this.context, this.message});

  SpokenLanguagesRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new SpokenLanguagesMessage.fromJson(json['message'])
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

class SpokenLanguagesMessage {
  SpokenLanguagesIntent? intent;

  SpokenLanguagesMessage({this.intent});

  SpokenLanguagesMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? new SpokenLanguagesIntent.fromJson(json['intent'])
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

class SpokenLanguagesIntent {
  SpokenLanguagesFulfillment? fulfillment;

  SpokenLanguagesIntent({this.fulfillment});

  SpokenLanguagesIntent.fromJson(Map<String, dynamic> json) {
    fulfillment = json['fulfillment'] != null
        ? new SpokenLanguagesFulfillment.fromJson(json['fulfillment'])
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

class SpokenLanguagesFulfillment {
  SpokenLanguagesAgent? agent;

  SpokenLanguagesFulfillment({this.agent});

  SpokenLanguagesFulfillment.fromJson(Map<String, dynamic> json) {
    agent = json['agent'] != null
        ? new SpokenLanguagesAgent.fromJson(json['agent'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.agent != null) {
      data['agent'] = this.agent!.toJson();
    }
    return data;
  }
}

class SpokenLanguagesAgent {
  SpokenLanguagesTags? tags;

  SpokenLanguagesAgent({this.tags});

  SpokenLanguagesAgent.fromJson(Map<String, dynamic> json) {
    tags = json['tags'] != null
        ? new SpokenLanguagesTags.fromJson(json['tags'])
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

class SpokenLanguagesTags {
  List<String>? orgUhiSpokenLangs;

  SpokenLanguagesTags({this.orgUhiSpokenLangs});

  SpokenLanguagesTags.fromJson(Map<String, dynamic> json) {
    orgUhiSpokenLangs = json['@org/uhi/spoken_langs'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@org/uhi/spoken_langs'] = this.orgUhiSpokenLangs;
    return data;
  }
}
