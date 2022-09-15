class SavePublicKeyModel {
  String? consumer;
  String? provider;
  String? sharedKey;

  SavePublicKeyModel({this.consumer, this.provider, this.sharedKey});

  SavePublicKeyModel.fromJson(Map<String, dynamic> json) {
    consumer = json['consumer'];
    provider = json['provider'];
    sharedKey = json['sharedKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['consumer'] = consumer;
    data['provider'] = provider;
    data['sharedKey'] = sharedKey;
    return data;
  }
}
