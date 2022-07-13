class LoginConfirmRequestModel {
  String? patientId;
  String? requesterId;
  String? transactionId;

  LoginConfirmRequestModel(
      {this.patientId, this.requesterId, this.transactionId});

  LoginConfirmRequestModel.fromJson(Map<String, dynamic> json) {
    patientId = json['patientId'];
    requesterId = json['requesterId'];
    transactionId = json['transactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['patientId'] = this.patientId;
    data['requesterId'] = this.requesterId;
    data['transactionId'] = this.transactionId;
    return data;
  }
}
