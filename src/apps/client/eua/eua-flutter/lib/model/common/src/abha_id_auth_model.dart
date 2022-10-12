class AbhaIdAuthModel {
  List<String>? authMethods;
  List<String>? blockedAuthMethods;
  String? healthIdNumber;
  String? healthid;
  String? status;
  String? authMethod;

  AbhaIdAuthModel(
      {this.authMethods,
      this.blockedAuthMethods,
      this.healthIdNumber,
      this.healthid,
      this.status,
      this.authMethod});

  AbhaIdAuthModel.fromJson(Map<String, dynamic> json) {
    authMethods =
        json['authMethods'] != null ? json['authMethods'].cast<String>() : null;
    blockedAuthMethods = json['blockedAuthMethods'] != null
        ? json['blockedAuthMethods'].cast<String>()
        : null;
    healthIdNumber =
        json['healthIdNumber'] != null ? json['healthIdNumber'] : null;
    healthid = json['healthid'] != null ? json['healthid'] : null;
    status = json['status'] != null ? json['status'] : null;
    authMethod = json['authMethod'] != null ? json['authMethod'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.authMethods != null) {
      data['authMethods'] = this.authMethods;
    }
    if (this.blockedAuthMethods != null) {
      data['blockedAuthMethods'] = this.blockedAuthMethods;
    }
    if (this.healthIdNumber != null) {
      data['healthIdNumber'] = this.healthIdNumber;
    }
    if (this.healthid != null) {
      data['healthid'] = this.healthid;
    }
    if (this.status != null) {
      data['status'] = this.status;
    }
    if (this.authMethod != null) {
      data['authMethod'] = this.authMethod;
    }
    return data;
  }
}
