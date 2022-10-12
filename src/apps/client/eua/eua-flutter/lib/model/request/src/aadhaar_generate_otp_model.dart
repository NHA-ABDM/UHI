class AadhaarGenerateOtpModel {
  String? aadhaar;
  bool? consent;

  AadhaarGenerateOtpModel({this.aadhaar, this.consent});

  AadhaarGenerateOtpModel.fromJson(Map<String, dynamic> json) {
    aadhaar = json['aadhaar'];
    consent = json['consent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aadhaar'] = this.aadhaar;
    data['consent'] = this.consent;
    return data;
  }
}
