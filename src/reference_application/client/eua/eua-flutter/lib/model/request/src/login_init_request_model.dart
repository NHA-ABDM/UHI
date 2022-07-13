class LoginInitRequestModel {
  String? authMode;
  String? purpose;
  LoginInitRequester? requester;
  String? value;

  LoginInitRequestModel(
      {this.authMode, this.purpose, this.requester, this.value});

  LoginInitRequestModel.fromJson(Map<String, dynamic> json) {
    authMode = json['authMode'];
    purpose = json['purpose'];
    requester = json['requester'] != null
        ? new LoginInitRequester.fromJson(json['requester'])
        : null;
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authMode'] = this.authMode;
    data['purpose'] = this.purpose;
    if (this.requester != null) {
      data['requester'] = this.requester!.toJson();
    }
    data['value'] = this.value;
    return data;
  }
}

class LoginInitRequester {
  String? id;
  String? type;

  LoginInitRequester({this.id, this.type});

  LoginInitRequester.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    return data;
  }
}
