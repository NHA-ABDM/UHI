class CreatePhrAddressRequestModel {
  bool? alreadyExistedPHR;
  String? password;
  String? phrAddress;
  String? sessionId;

  CreatePhrAddressRequestModel(
      {this.alreadyExistedPHR, this.password, this.phrAddress, this.sessionId});

  CreatePhrAddressRequestModel.fromJson(Map<String, dynamic> json) {
    alreadyExistedPHR = json['alreadyExistedPHR'];
    password = json['password'];
    phrAddress = json['phrAddress'];
    sessionId = json['sessionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alreadyExistedPHR'] = this.alreadyExistedPHR;
    data['password'] = this.password;
    data['phrAddress'] = this.phrAddress;
    data['sessionId'] = this.sessionId;
    return data;
  }
}
