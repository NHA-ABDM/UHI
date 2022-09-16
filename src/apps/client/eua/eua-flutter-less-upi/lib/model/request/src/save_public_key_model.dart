class SavePublicKeyModel {
  String? userName;
  String? publicKey;
  String? privateKey;

  SavePublicKeyModel({this.userName, this.publicKey, this.privateKey});

  SavePublicKeyModel.fromJson(Map<String, dynamic> json) {
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
