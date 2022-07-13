class FCMTokenModel {
  String? userName;
  String? token;
  String? deviceId;
  String? type;

  FCMTokenModel({this.userName, this.token, this.deviceId, this.type});

  FCMTokenModel.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    token = json['token'];
    deviceId = json['deviceId'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['token'] = this.token;
    data['deviceId'] = this.deviceId;
    data['type'] = this.type;
    return data;
  }
}
