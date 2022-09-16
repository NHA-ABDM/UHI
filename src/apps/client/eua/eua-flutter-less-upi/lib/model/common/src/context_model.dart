class ContextModel {
  String? domain;
  String? country;
  String? city;
  String? action;
  String? coreVersion;
  String? consumerId;
  String? consumerUri;
  // String? bppId;
  // String? bppUri;
  String? messageId;
  String? timestamp;
  String? deviceId;
  String? transactionId;
  String? providerUrl;

  ContextModel(
      {this.domain,
      this.country,
      this.city,
      this.action,
      this.coreVersion,
      this.consumerId,
      this.consumerUri,
      // this.bppId,
      // this.bppUri,
      this.messageId,
      this.timestamp,
      this.deviceId,
      this.transactionId,
      this.providerUrl});

  ContextModel.fromJson(Map<String, dynamic> json) {
    domain = json['domain'];
    country = json['country'];
    city = json['city'];
    action = json['action'];
    coreVersion = json['core_version'];
    consumerId = json['consumer_id'];
    consumerUri = json['consumer_uri'];
    // bppId = json['bap_id'];
    // bppUri = json['bap_uri'];
    messageId = json['message_id'];
    timestamp = json['timestamp'];
    deviceId = json['device_id'];
    transactionId = json['transaction_id'];
    if (json["provider_uri"] != null) {
      providerUrl = json["provider_uri"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['domain'] = this.domain;
    data['country'] = this.country;
    data['city'] = this.city;
    data['action'] = this.action;
    data['core_version'] = this.coreVersion;
    data['consumer_id'] = this.consumerId;
    data['consumer_uri'] = this.consumerUri;
    // if (this.bppId != null) {
    //   data['bpp_id'] = this.bppId;
    // }
    // if (this.bppUri != null) {
    //   data['bpp_uri'] = this.bppUri;
    // }

    data['message_id'] = this.messageId;
    data['timestamp'] = this.timestamp;
    if (this.deviceId != null) {
      data['device_id'] = this.deviceId;
    }
    if (this.providerUrl != null) {
      data['provider_uri'] = this.providerUrl;
    }
    data['transaction_id'] = this.transactionId;
    return data;
  }
}
