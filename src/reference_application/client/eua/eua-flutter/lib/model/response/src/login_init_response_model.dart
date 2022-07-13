class LoginInitResponseModel {
  String? transactionId;
  String? requesterId;
  String? authMode;
  String? error;

  LoginInitResponseModel(
      {this.transactionId, this.requesterId, this.authMode, this.error});

  LoginInitResponseModel.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'];
    requesterId = json['requesterId'];
    authMode = json['authMode'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionId'] = this.transactionId;
    data['requesterId'] = this.requesterId;
    data['authMode'] = this.authMode;
    data['error'] = this.error;
    return data;
  }
}
