import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/response.dart';
import 'package:uhi_flutter_app/model/response/src/booking_on_init_response_model.dart';

class BookOnConfirmResponseModel {
  ContextModel? context;
  BookOnConfirmResponseMessage? message;

  BookOnConfirmResponseModel({this.context, this.message});

  BookOnConfirmResponseModel.fromJson(Map<String, dynamic> json) {
    context = json['context'] != null
        ? new ContextModel.fromJson(json['context'])
        : null;
    message = json['message'] != null
        ? new BookOnConfirmResponseMessage.fromJson(json['message'])
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

class BookOnConfirmResponseMessage {
  BookingConfirmResponseOrder? order;

  BookOnConfirmResponseMessage({this.order});

  BookOnConfirmResponseMessage.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null
        ? new BookingConfirmResponseOrder.fromJson(json['order'])
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

class BookingConfirmResponseOrder {
  String? id;
  DiscoveryProviders? provider;
  DiscoveryItems? item;
  Fulfillment? fulfillment;
  Billing? billing;
  Quote? quote;
  Payment? payment;
  Customer? customer;

  BookingConfirmResponseOrder(
      {this.id,
      this.provider,
      this.item,
      this.fulfillment,
      this.billing,
      this.quote,
      this.payment,
      this.customer});

  BookingConfirmResponseOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    //state = json['state'];
    provider = json['provider'] != null
        ? new DiscoveryProviders.fromJson(json['provider'])
        : null;
    item =
        json['item'] != null ? new DiscoveryItems.fromJson(json['item']) : null;
    fulfillment = json['fulfillment'] != null
        ? new Fulfillment.fromJson(json['fulfillment'])
        : null;
    billing =
        json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    quote = json['quote'] != null ? new Quote.fromJson(json['quote']) : null;
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.provider != null) {
      data['provider'] = this.provider!.toJson();
    }
    if (this.item != null) {
      data['item'] = this.item!.toJson();
    }
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment!.toJson();
    }
    if (this.billing != null) {
      data['billing'] = this.billing!.toJson();
    }
    if (this.quote != null) {
      data['quote'] = this.quote!.toJson();
    }
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}

// class Provider {
//   String? id;
//   DiscoveryDescriptor? descriptor;

//   Provider({this.id, this.descriptor});

//   Provider.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     descriptor = json['descriptor'] != null
//         ? new DiscoveryDescriptor.fromJson(json['descriptor'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     if (this.descriptor != null) {
//       data['descriptor'] = this.descriptor!.toJson();
//     }
//     return data;
//   }
// }

// class Item {
//   String? id;
//   DiscoveryDescriptor? descriptor;
//   String? fulfillmentId;
//   Price? price;
//   Quantity? quantity;

//   Item(
//       {this.id,
//       this.descriptor,
//       this.fulfillmentId,
//       this.price,
//       this.quantity});

//   Item.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     descriptor = json['descriptor'] != null
//         ? new DiscoveryDescriptor.fromJson(json['descriptor'])
//         : null;
//     fulfillmentId = json['fulfillment_id'];
//     price = json['price'] != null ? new Price.fromJson(json['price']) : null;
//     quantity = json['quantity'] != null
//         ? new Quantity.fromJson(json['quantity'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     if (this.descriptor != null) {
//       data['descriptor'] = this.descriptor!.toJson();
//     }
//     data['fulfillment_id'] = this.fulfillmentId;
//     if (this.price != null) {
//       data['price'] = this.price!.toJson();
//     }
//     if (this.quantity != null) {
//       data['quantity'] = this.quantity!.toJson();
//     }
//     return data;
//   }
// }

class Quantity {
  Available? available;

  Quantity({this.available});

  Quantity.fromJson(Map<String, dynamic> json) {
    available = json['available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available'] = this.available;
    return data;
  }
}

class Available {
  String? count;
  Available({this.count});

  Available.fromJson(Map<String, dynamic> json) {
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    return data;
  }
}

class OnConfirmFulfillment {
  String? id;
  String? type;
  Agent? agent;
  Start? start;
  Start? end;
  OnConfirmCustomer? customer;

  OnConfirmFulfillment(
      {this.id, this.type, this.agent, this.start, this.end, this.customer});

  OnConfirmFulfillment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    agent = json['agent'] != null ? new Agent.fromJson(json['agent']) : null;
    start = json['start'] != null ? new Start.fromJson(json['start']) : null;
    end = json['end'] != null ? new Start.fromJson(json['end']) : null;
    customer = json['customer'] != null
        ? new OnConfirmCustomer.fromJson(json['customer'])
        : null;
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
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}

class Agent {
  String? id;
  String? name;
  String? gender;
  String? image;

  Agent({this.id, this.name, this.gender, this.image});

  Agent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    gender = json['gender'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['image'] = this.image;
    return data;
  }
}

class OnConfirmCustomer {
  String? id;
  Person? person;
  Contact? contact;

  OnConfirmCustomer({this.id, this.person, this.contact});

  OnConfirmCustomer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    person =
        json['person'] != null ? new Person.fromJson(json['person']) : null;
    contact =
        json['contact'] != null ? new Contact.fromJson(json['contact']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.person != null) {
      data['person'] = this.person!.toJson();
    }
    if (this.contact != null) {
      data['contact'] = this.contact!.toJson();
    }
    return data;
  }
}

class Person {
  String? name;
  String? gender;

  Person({this.name, this.gender});

  Person.fromJson(Map<String, dynamic> json) {
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

class Contact {
  String? phone;
  String? email;

  Contact({this.phone, this.email});

  Contact.fromJson(Map<String, dynamic> json) {
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

// class Payment {
//   String? uri;
//   String? tlMethod;
//   Params? params;
//   String? type;
//   String? status;

//   Payment({this.uri, this.tlMethod, this.params, this.type, this.status});

//   Payment.fromJson(Map<String, dynamic> json) {
//     uri = json['uri'];
//     tlMethod = json['tl_method'];
//     params =
//         json['params'] != null ? new Params.fromJson(json['params']) : null;
//     type = json['type'];
//     status = json['status'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['uri'] = this.uri;
//     data['tl_method'] = this.tlMethod;
//     if (this.params != null) {
//       data['params'] = this.params!.toJson();
//     }
//     data['type'] = this.type;
//     data['status'] = this.status;
//     return data;
//   }
// }

// class Params {
//   String? transactionId;
//   String? amount;
//   String? mode;
//   String? vpa;

//   Params({this.transactionId, this.amount, this.mode, this.vpa});

//   Params.fromJson(Map<String, dynamic> json) {
//     transactionId = json['transaction_id'];
//     amount = json['amount'];
//     mode = json['mode'];
//     vpa = json['vpa'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['transaction_id'] = this.transactionId;
//     data['amount'] = this.amount;
//     data['mode'] = this.mode;
//     data['vpa'] = this.vpa;
//     return data;
//   }
// }
