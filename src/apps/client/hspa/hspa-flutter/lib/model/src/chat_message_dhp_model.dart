
import 'context_model.dart';

class ChatMessageDhpModel {
  ContextModel? context;
  ChatMessage? message;

  ChatMessageDhpModel({this.context, this.message});

  ChatMessageDhpModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? ChatMessage.fromJson(json['message'])
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

class ChatMessage {
  ChatIntent? intent;

  ChatMessage({this.intent});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    intent =
        json['intent'] != null ? ChatIntent.fromJson(json['intent']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (intent != null) {
      data['intent'] = intent!.toJson();
    }
    return data;
  }
}

class ChatIntent {
  ChatMsg? chat;

  ChatIntent({this.chat});

  ChatIntent.fromJson(Map<String, dynamic> json) {
    chat = json['chat'] != null ? ChatMsg.fromJson(json['chat']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chat != null) {
      data['chat'] = chat!.toJson();
    }
    return data;
  }
}

class ChatMsg {
  Sender? sender;
  Sender? receiver;
  Content? content;
  ChatTime? time;

  ChatMsg({this.sender, this.receiver, this.content, this.time});

  ChatMsg.fromJson(Map<String, dynamic> json) {
    sender =
        json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    receiver =
        json['receiver'] != null ? Sender.fromJson(json['receiver']) : null;
    content =
        json['content'] != null ? Content.fromJson(json['content']) : null;
    time = json['time'] != null ? ChatTime.fromJson(json['time']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    if (receiver != null) {
      data['receiver'] = receiver!.toJson();
    }
    if (content != null) {
      data['content'] = content!.toJson();
    }
    if (time != null) {
      data['time'] = time!.toJson();
    }
    return data;
  }
}

class Sender {
  Person? person;

  Sender({this.person});

  Sender.fromJson(Map<String, dynamic> json) {
    person =
        json['person'] != null ? Person.fromJson(json['person']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (person != null) {
      data['person'] = person!.toJson();
    }
    return data;
  }
}

class Person {
  String? name;
  String? image;
  String? cred;
  String? gender;

  Person({this.name, this.image, this.cred, this.gender});

  Person.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    cred = json['cred'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    data['cred'] = cred;
    data['gender'] = gender;
    return data;
  }
}

class Content {
  String? contentId;
  String? contentValue;
  String? contentType;
  String? contentUrl;
  String? contentFilename;

  Content({this.contentId, this.contentValue, this.contentType, this.contentFilename});

  Content.fromJson(Map<String, dynamic> json) {
    contentId = json['content_id'];
    contentValue = json['content_value'];
    contentType = json['content_type'];
    contentUrl = json['content_url'];
    contentFilename = json['content_fileName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content_id'] = contentId;
    data['content_value'] = contentValue;
    data['content_type'] = contentType;
    data['content_url'] = contentUrl;
    data['content_fileName'] = contentFilename;
    return data;
  }
}

class ChatTime {
  String? timestamp;

  ChatTime({this.timestamp});

  ChatTime.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    return data;
  }
}
