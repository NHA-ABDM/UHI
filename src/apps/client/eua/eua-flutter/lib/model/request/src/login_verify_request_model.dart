class LoginVerifyRequestModel {
  String? authCode;
  String? requesterId;
  String? transactionId;

  LoginVerifyRequestModel(
      {this.authCode, this.requesterId, this.transactionId});

  LoginVerifyRequestModel.fromJson(Map<String, dynamic> json) {
    authCode = json['authCode'];
    requesterId = json['requesterId'];
    transactionId = json['transactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authCode'] = this.authCode;
    data['requesterId'] = this.requesterId;
    data['transactionId'] = this.transactionId;
    return data;
  }
}
