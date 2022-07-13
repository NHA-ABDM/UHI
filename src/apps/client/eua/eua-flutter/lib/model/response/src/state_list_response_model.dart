class StateListResponseModel {
  String? stateName;
  String? stateCode;

  StateListResponseModel({this.stateName, this.stateCode});

  StateListResponseModel.fromJson(Map<String, dynamic> json) {
    stateName = json['stateName'];
    stateCode = json['stateCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stateName'] = this.stateName;
    data['stateCode'] = this.stateCode;
    return data;
  }
}
