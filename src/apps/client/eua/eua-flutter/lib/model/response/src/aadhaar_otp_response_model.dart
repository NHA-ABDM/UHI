class AadhaarOtpResponseModel {
  String? mobileNumber;
  String? txnId;

  AadhaarOtpResponseModel({this.mobileNumber, this.txnId});

  AadhaarOtpResponseModel.fromJson(Map<String, dynamic> json) {
    mobileNumber = json['mobileNumber'];
    txnId = json['txnId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobileNumber'] = this.mobileNumber;
    data['txnId'] = this.txnId;
    return data;
  }
}
