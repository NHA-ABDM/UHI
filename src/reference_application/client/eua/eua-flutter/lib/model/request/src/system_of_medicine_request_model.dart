import 'package:uhi_flutter_app/model/model.dart';

class SystemOfMedicineRequestModel {
  ContextModel? context;
  SystemOfMedicineMessage? message;

  SystemOfMedicineRequestModel({this.context, this.message});

  SystemOfMedicineRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new SystemOfMedicineMessage.fromJson(json['message'])
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

class SystemOfMedicineMessage {
  SystemOfMedicineIntent? intent;

  SystemOfMedicineMessage({this.intent});

  SystemOfMedicineMessage.fromJson(Map<String, dynamic> json) {
    intent = json['intent'] != null
        ? new SystemOfMedicineIntent.fromJson(json['intent'])
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

class SystemOfMedicineIntent {
  SystemOfMedicineCategory? category;

  SystemOfMedicineIntent({this.category});

  SystemOfMedicineIntent.fromJson(Map<String, dynamic> json) {
    category = json['category'] != null
        ? new SystemOfMedicineCategory.fromJson(json['category'])
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

class SystemOfMedicineCategory {
  SystemOfMedicineDescriptor? descriptor;

  SystemOfMedicineCategory({this.descriptor});

  SystemOfMedicineCategory.fromJson(Map<String, dynamic> json) {
    descriptor = json['descriptor'] != null
        ? new SystemOfMedicineDescriptor.fromJson(json['descriptor'])
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

class SystemOfMedicineDescriptor {
  String? name;

  SystemOfMedicineDescriptor({this.name});

  SystemOfMedicineDescriptor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
