class DistrictListResponseModel {
  String? code;
  String? name;

  DistrictListResponseModel({this.code, this.name});

  DistrictListResponseModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}
