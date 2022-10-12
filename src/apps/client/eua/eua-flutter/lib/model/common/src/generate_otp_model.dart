class GenerateOtpModel {
  String? authMode;
  String? value;

  GenerateOtpModel({this.authMode, this.value});

  GenerateOtpModel.fromJson(Map<String, dynamic> json) {
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
