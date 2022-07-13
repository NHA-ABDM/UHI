import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';

class BookingOnInitResponseModel {
  ContextModel? context;
  Message? message;

  BookingOnInitResponseModel({this.context, this.message});

  BookingOnInitResponseModel.fromJson(Map<String, dynamic> json) {
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

class BookingInitResponseOrder {
  // String? id;
  // String? state;
  // Provider? provider;
  DiscoveryItems? item;
  Fulfillment? fulfillment;
  Billing? billing;
  Customer? customer;
  Quote? quote;
  Payment? payment;

  BookingInitResponseOrder(
      {
      // this.id,
      // this.state,
      // this.provider,
      this.item,
      this.fulfillment,
      this.billing,
      this.customer,
      this.quote,
      this.payment});

  BookingInitResponseOrder.fromJson(Map<String, dynamic> json) {
    // id = json['id'];
    // state = json['state'];
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
    quote = json['quote'] != null ? new Quote.fromJson(json['quote']) : null;
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    // data['state'] = this.state;
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
    if (this.quote != null) {
      data['quote'] = this.quote!.toJson();
    }
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    return data;
  }
}

class Price {
  String? currency;
  String? value;

  Price({this.currency, this.value});

  Price.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['value'] = this.value;
    return data;
  }
}

class Quote {
  DiscoveryPrice? price;
  List<Breakup>? breakup;

  Quote({this.price, this.breakup});

  Quote.fromJson(Map<String, dynamic> json) {
    price = json['price'] != null
        ? new DiscoveryPrice.fromJson(json['price'])
        : null;
    if (json['breakup'] != null) {
      breakup = <Breakup>[];
      json['breakup'].forEach((v) {
        breakup!.add(new Breakup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.price != null) {
      data['price'] = this.price!.toJson();
    }
    if (this.breakup != null) {
      data['breakup'] = this.breakup!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Breakup {
  String? title;
  DiscoveryPrice? price;

  Breakup({this.title, this.price});

  Breakup.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    price = json['price'] != null
        ? new DiscoveryPrice.fromJson(json['price'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.price != null) {
      data['price'] = this.price!.toJson();
    }
    return data;
  }
}

class Payment {
  String? uri;
  String? tlMethod;
  Params? params;
  String? type;
  String? status;

  Payment({this.uri, this.tlMethod, this.params, this.type, this.status});

  Payment.fromJson(Map<String, dynamic> json) {
    uri = json['uri'];
    tlMethod = json['tl_method'];
    params =
        json['params'] != null ? new Params.fromJson(json['params']) : null;
    type = json['type'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uri'] = this.uri;
    data['tl_method'] = this.tlMethod;
    if (this.params != null) {
      data['params'] = this.params!.toJson();
    }
    data['type'] = this.type;
    data['status'] = this.status;
    return data;
  }
}

class Params {
  String? amount;
  String? mode;
  String? vpa;
  String? transactionId;

  Params({this.amount, this.mode, this.vpa});

  Params.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    mode = json['mode'];
    vpa = json['vpa'];
    transactionId = json['transaction_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['mode'] = this.mode;
    data['vpa'] = this.vpa;
    data['transaction_id'] = this.transactionId;
    return data;
  }
}
