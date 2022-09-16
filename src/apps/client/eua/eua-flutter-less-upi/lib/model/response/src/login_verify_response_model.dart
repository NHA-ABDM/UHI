class LoginVerifyResponseModel {
  String? transactionId;
  String? requesterId;
  String? mobileEmail;
  List<String>? mappedPhrAddress;

  LoginVerifyResponseModel(
      {this.transactionId,
      this.requesterId,
      this.mobileEmail,
      this.mappedPhrAddress});

  LoginVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'];
    requesterId = json['requesterId'];
    mobileEmail = json['mobileEmail'];
    mappedPhrAddress = json['mappedPhrAddress'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionId'] = this.transactionId;
    data['requesterId'] = this.requesterId;
    data['mobileEmail'] = this.mobileEmail;
    data['mappedPhrAddress'] = this.mappedPhrAddress;
    return data;
  }
}
