class VerifyAadhaarOtpRequestModel {
  String? otp;
  String? txnId;

  VerifyAadhaarOtpRequestModel({this.otp, this.txnId});

  VerifyAadhaarOtpRequestModel.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    txnId = json['txnId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp'] = this.otp;
    data['txnId'] = this.txnId;
    return data;
  }
}
