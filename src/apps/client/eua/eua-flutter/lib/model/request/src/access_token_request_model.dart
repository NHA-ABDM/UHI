class AccessTokenRequestModel {
  String? clientId;
  String? clientSecret;
  String? grantType;

  AccessTokenRequestModel({this.clientId, this.clientSecret, this.grantType});

  AccessTokenRequestModel.fromJson(Map<String, dynamic> json) {
    clientId = json['clientId'];
    clientSecret = json['clientSecret'];
    grantType = json['grantType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clientId'] = clientId;
    data['clientSecret'] = clientSecret;
    data['grantType'] = grantType;
    return data;
  }
}
