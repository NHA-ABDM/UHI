import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_on_init_response_model.dart';

class BookingConfirmResponseModel {
  ContextModel? context;
  Message? message;

  BookingConfirmResponseModel({this.context, this.message});

  BookingConfirmResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? state;
  DiscoveryItems? item;
  Billing? billing;
  Fulfillment? fulfillment;
  Quote? quote;
  Payment? payment;
  Customer? customer;

  Order(
      {this.id,
      this.state,
      this.item,
      this.billing,
      this.fulfillment,
      this.quote,
      this.payment,
      this.customer});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    state = json['state'];
    item =
        json['item'] != null ? new DiscoveryItems.fromJson(json['item']) : null;
    billing =
        json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    fulfillment = json['fulfillment'] != null
        ? new Fulfillment.fromJson(json['fulfillment'])
        : null;
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
    data['state'] = this.state;
    if (this.item != null) {
      data['item'] = this.item!.toJson();
    }
    if (this.billing != null) {
      data['billing'] = this.billing!.toJson();
    }
    if (this.fulfillment != null) {
      data['fulfillment'] = this.fulfillment!.toJson();
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
