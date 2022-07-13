import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_on_init_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';

class BookingConfirmRequestModel {
  ContextModel? context;
  Message? message;

  BookingConfirmRequestModel({this.context, this.message});

  BookingConfirmRequestModel.fromJson(Map<String, dynamic> json) {
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

class BookingConfirmRequestOrder {
  String? id;
  String? state;
  DiscoveryProviders? provider;
  DiscoveryItems? item;
  Fulfillment? fulfillment;
  Billing? billing;
  Customer? customer;
  Quote? quote;
  Payment? payment;

  BookingConfirmRequestOrder(
      {this.id,
      this.state,
      this.provider,
      this.item,
      this.fulfillment,
      this.billing,
      this.customer,
      this.quote,
      this.payment});

  BookingConfirmRequestOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    state = json['state'];
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
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    quote = json['quote'] != null ? new Quote.fromJson(json['quote']) : null;
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['state'] = this.state;
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

// class Breakup {
//   String? title;
//   Price? price;

//   Breakup({this.title, this.price});

//   Breakup.fromJson(Map<String, dynamic> json) {
//     title = json['title'];
//     price = json['price'] != null ? new Price.fromJson(json['price']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['title'] = this.title;
//     if (this.price != null) {
//       data['price'] = this.price!.toJson();
//     }
//     return data;
//   }
// }

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
