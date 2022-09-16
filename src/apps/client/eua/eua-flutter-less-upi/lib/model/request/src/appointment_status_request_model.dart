import '../../model.dart';

class AppointmentStatusRequestModel {
  ContextModel? context;
  AppointmentStatusMessage? message;

  AppointmentStatusRequestModel({this.context, this.message});

  AppointmentStatusRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new AppointmentStatusMessage.fromJson(json['message'])
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

class AppointmentStatusMessage {
  AppointmentStatusOrder? order;

  AppointmentStatusMessage({this.order});

  AppointmentStatusMessage.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null
        ? new AppointmentStatusOrder.fromJson(json['order'])
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

class AppointmentStatusOrder {
  String? id;
  String? refId;
  AppointmentStatusCustomer? customer;

  AppointmentStatusOrder({this.id, this.refId, this.customer});

  AppointmentStatusOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    refId = json['ref_id'];
    customer = json['customer'] != null
        ? new AppointmentStatusCustomer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ref_id'] = this.refId;
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}

class AppointmentStatusCustomer {
  String? id;
  String? cred;
  AppointmentStatusPerson? person;
  AppointmentStatusContact? contact;

  AppointmentStatusCustomer({this.id, this.cred, this.person, this.contact});

  AppointmentStatusCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cred = json['cred'];
    person = json['person'] != null
        ? new AppointmentStatusPerson.fromJson(json['person'])
        : null;
    contact = json['contact'] != null
        ? new AppointmentStatusContact.fromJson(json['contact'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cred'] = this.cred;
    if (this.person != null) {
      data['person'] = this.person!.toJson();
    }
    if (this.contact != null) {
      data['contact'] = this.contact!.toJson();
    }
    return data;
  }
}

class AppointmentStatusPerson {
  String? name;
  String? gender;

  AppointmentStatusPerson({this.name, this.gender});

  AppointmentStatusPerson.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['gender'] = this.gender;
    return data;
  }
}

class AppointmentStatusContact {
  String? phone;
  String? email;

  AppointmentStatusContact({this.phone, this.email});

  AppointmentStatusContact.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['email'] = this.email;
    return data;
  }
}
