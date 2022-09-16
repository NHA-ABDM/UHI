import 'package:uhi_flutter_app/model/model.dart';

class SpecialityRequestModel {
  ContextModel? context;
  SpecialityMessage? message;

  SpecialityRequestModel({this.context, this.message});

  SpecialityRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new SpecialityMessage.fromJson(json['message'])
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

class SpecialityMessage {
  SpecialityIntent? intent;

  SpecialityMessage({this.intent});

  SpecialityMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? new SpecialityIntent.fromJson(json['intent'])
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

class SpecialityIntent {
  SpecialityCategory? category;

  SpecialityIntent({this.category});

  SpecialityIntent.fromJson(Map<String, dynamic> json) {
    category = json['category'] != null
        ? new SpecialityCategory.fromJson(json['category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    return data;
  }
}

class SpecialityCategory {
  SpecialityDescriptor? descriptor;

  SpecialityCategory({this.descriptor});

  SpecialityCategory.fromJson(Map<String, dynamic> json) {
    descriptor = json['descriptor'] != null
        ? new SpecialityDescriptor.fromJson(json['descriptor'])
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

class SpecialityDescriptor {
  String? name;

  SpecialityDescriptor({this.name});

  SpecialityDescriptor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
