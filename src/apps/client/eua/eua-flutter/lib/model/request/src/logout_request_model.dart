class LogoutRequestModel {
  String? clientId;
  String? clientSecret;
  String? grantType;

  LogoutRequestModel({this.clientId, this.clientSecret, this.grantType});

  LogoutRequestModel.fromJson(Map<String, dynamic> json) {
    clientId = json['clientId'];
    clientSecret = json['clientSecret'];
    grantType = json['grantType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['clientId'] = this.clientId;
    data['clientSecret'] = this.clientSecret;
    data['grantType'] = this.grantType;
    return data;
  }
}
