class DoctorImageModel {
  String? doctorHprAddress;
  String? doctorImage;

  DoctorImageModel({this.doctorHprAddress, this.doctorImage});

  DoctorImageModel.fromJson(Map<String, dynamic> json) {
    doctorHprAddress = json['doctorHprAddress'];
    doctorImage = json['doctorImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['doctorHprAddress'] = this.doctorHprAddress;
    data['doctorImage'] = this.doctorImage;
    return data;
  }
}
