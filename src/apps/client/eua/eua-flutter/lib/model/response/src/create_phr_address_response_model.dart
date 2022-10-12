class CreatePhrAddressResponseModel {
  String? phrAddress;
  String? token;

  CreatePhrAddressResponseModel({this.phrAddress, this.token});

  CreatePhrAddressResponseModel.fromJson(Map<String, dynamic> json) {
    phrAddress = json['phrAddress'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phrAddress'] = this.phrAddress;
    data['token'] = this.token;
    return data;
  }
}
