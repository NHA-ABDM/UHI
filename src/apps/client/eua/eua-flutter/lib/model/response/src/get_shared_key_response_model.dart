class GetSharedKeyResponseModel {
  String? userName;
  String? publicKey;
  Null privateKey;

  GetSharedKeyResponseModel({this.userName, this.publicKey, this.privateKey});

  GetSharedKeyResponseModel.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    publicKey = json['publicKey'];
    privateKey = json['privateKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['publicKey'] = this.publicKey;
    data['privateKey'] = this.privateKey;
    return data;
  }
}
