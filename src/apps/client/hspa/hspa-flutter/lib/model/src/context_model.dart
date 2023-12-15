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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['domain'] = domain;
    data['country'] = country;
    data['city'] = city;
    data['action'] = action;
    data['core_version'] = coreVersion;
    data['consumer_id'] = consumerId;
    data['consumer_uri'] = consumerUri;
    // if (this.bppId != null) {
    //   data['bpp_id'] = this.bppId;
    // }
    // if (this.bppUri != null) {
    //   data['bpp_uri'] = this.bppUri;
    // }

    data['message_id'] = messageId;
    data['timestamp'] = timestamp;
    if (deviceId != null) {
      data['device_id'] = deviceId;
    }
    if (providerUrl != null) {
      data['provider_uri'] = providerUrl;
    }
    data['transaction_id'] = transactionId;
    return data;
  }
}
