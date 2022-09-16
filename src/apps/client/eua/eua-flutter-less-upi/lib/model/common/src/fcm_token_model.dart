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
    if (this.userName != null) {
      data['userName'] = this.userName;
    }
    // data['userName'] = this.userName;
    if (this.token != null) {
      data['token'] = this.token;
    }
    // data['token'] = this.token;
    if (this.deviceId != null) {
      data['deviceId'] = this.deviceId;
    }
    // data['deviceId'] = this.deviceId;
    if (this.type != null) {
      data['type'] = this.type;
    }
    // data['type'] = this.type;
    return data;
  }
}
