class RegistrationGenerateOtpRequestModel {
  String? authMode;
  String? value;

  RegistrationGenerateOtpRequestModel({this.authMode, this.value});

  RegistrationGenerateOtpRequestModel.fromJson(Map<String, dynamic> json) {
    authMode = json['authMode'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authMode'] = this.authMode;
    data['value'] = this.value;
    return data;
  }
}
