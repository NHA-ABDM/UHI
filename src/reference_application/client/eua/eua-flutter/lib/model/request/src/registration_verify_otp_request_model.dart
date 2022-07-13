class RegistrationVerifyOTPRequestModel {
  String? sessionId;
  String? value;

  RegistrationVerifyOTPRequestModel({this.sessionId, this.value});

  RegistrationVerifyOTPRequestModel.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['value'] = this.value;
    return data;
  }
}
