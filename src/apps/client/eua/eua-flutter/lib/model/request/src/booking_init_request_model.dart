import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';

class BookingInitRequestModel {
  ContextModel? context;
  Message? message;

  BookingInitRequestModel({this.context, this.message});

  BookingInitRequestModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message =
        json['message'] != null ? new Message.fromJson(json['message']) : null;
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

class Message {
  Order? order;

  Message({this.order});

  Message.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    return data;
  }
}

class Order {
  DiscoveryItems? item;
  Fulfillment? fulfillment;
  Billing? billing;
  Customer? customer;
  String? id;

  Order({
    this.item,
    this.fulfillment,
    this.billing,
    this.customer,
    this.id,
  });

  Order.fromJson(Map<String, dynamic> json) {
    // provider = json['provider'] != null
    //     ? new Provider.fromJson(json['provider'])
    //     : null;

    item =
        json['item'] != null ? new DiscoveryItems.fromJson(json['item']) : null;
    fulfillment = json['fulfillment'] != null
        ? new Fulfillment.fromJson(json['fulfillment'])
        : null;
    billing =
        json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // if (this.provider != null) {
    //   data['provider'] = this.provider!.toJson();
    // }
    if (this.item != null) {
      data['item'] = this.item!.toJson();
    }
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment!.toJson();
    }
    if (this.billing != null) {
      data['billing'] = this.billing!.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    data['id'] = this.id;

    return data;
  }
}

class Fulfillment {
  String? id;
  String? type;
  DiscoveryAgent? agent;
  Start? start;
  Start? end;
  InitTimeSlotTags? initTimeSlotTags;
  // Tags? tags;

  Fulfillment({
    this.id,
    this.type,
    this.agent,
    this.start,
    this.end,
    this.initTimeSlotTags,
    // this.tags,
  });

  Fulfillment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    agent = json['agent'] != null
        ? new DiscoveryAgent.fromJson(json['agent'])
        : null;
    start = json['start'] != null ? new Start.fromJson(json['start']) : null;
    end = json['end'] != null ? new Start.fromJson(json['end']) : null;
    initTimeSlotTags = json['tags'] != null
        ? new InitTimeSlotTags.fromJson(json['tags'])
        : null;
    // tags = json['tags'] != null ? new Tags.fromJson(json['tags']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    if (this.agent != null) {
      data['agent'] = this.agent!.toJson();
    }
    if (this.start != null) {
      data['start'] = this.start!.toJson();
    }
    if (this.end != null) {
      data['end'] = this.end!.toJson();
    }
    if (this.initTimeSlotTags != null) {
      data['tags'] = this.initTimeSlotTags!.toJson();
    }
    // if (this.tags != null) {
    //   data['tags'] = this.tags!.toJson();
    // }
    return data;
  }
}

class Start {
  Time? time;

  Start({this.time});

  Start.fromJson(Map<String, dynamic> json) {
    time = json['time'] != null ? new Time.fromJson(json['time']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.time != null) {
      data['time'] = this.time!.toJson();
    }
    return data;
  }
}

class Time {
  String? timestamp;

  Time({this.timestamp});

  Time.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class InitTimeSlotTags {
  String? abdmGovInSlotId;
  String? slotId;
  String? patientKey;
  String? doctorKey;

  InitTimeSlotTags({
    this.abdmGovInSlotId,
    this.patientKey,
    this.doctorKey,
    this.slotId,
  });

  InitTimeSlotTags.fromJson(Map<String, dynamic> json) {
    abdmGovInSlotId = json['@abdm/gov.in/slot_id'];
    patientKey = json['@abdm/gov.in/patient_key'];
    doctorKey = json['@abdm/gov.in/doctors_key'];
    if (json['@abdm/gov.in/slot'] != null) {
      slotId = json['@abdm/gov.in/slot'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.abdmGovInSlotId != null) {
      data['@abdm/gov.in/slot_id'] = this.abdmGovInSlotId;
    }
    if (this.patientKey != null) {
      data['@abdm/gov.in/patient_key'] = this.patientKey;
    }
    if (this.doctorKey != null) {
      data['@abdm/gov.in/doctors_key'] = this.doctorKey;
    }
    if (this.slotId != null) {
      data['@abdm/gov.in/slot'] = this.slotId;
    }

    return data;
  }
}

class Billing {
  String? name;
  Address? address;
  String? email;
  String? phone;

  Billing({this.name, this.address, this.email, this.phone});

  Billing.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Address {
  String? door;
  String? name;
  String? locality;
  String? city;
  String? state;
  String? country;
  String? areaCode;

  Address(
      {this.door,
      this.name,
      this.locality,
      this.city,
      this.state,
      this.country,
      this.areaCode});

  Address.fromJson(Map<String, dynamic> json) {
    door = json['door'];
    name = json['name'];
    locality = json['locality'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    areaCode = json['area_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['door'] = this.door;
    data['name'] = this.name;
    data['locality'] = this.locality;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['area_code'] = this.areaCode;
    return data;
  }
}

class Customer {
  String? id;
  String? cred;

  Customer({this.id, this.cred});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cred = json['cred'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cred'] = this.cred;
    return data;
  }
}
