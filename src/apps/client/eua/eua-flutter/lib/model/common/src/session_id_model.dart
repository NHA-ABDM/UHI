class SessionIdModel {
  String? sessionId;

  SessionIdModel({this.sessionId});

  SessionIdModel.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    return data;
  }
}
