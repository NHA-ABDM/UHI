class NotificationMessageModel {
  String? type;
  String? doctorAbhaAddress;
  String? patientAbhaAddress;
  // String? doctorName;
  String? doctorGender;
  String? providerUri;

  NotificationMessageModel(
      {this.type,
      this.doctorAbhaAddress,
      this.patientAbhaAddress,
      // this.doctorName,
      this.doctorGender,
      this.providerUri});

  NotificationMessageModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    doctorAbhaAddress = json['senderAbhaAddress'];
    patientAbhaAddress = json['receiverAbhaAddress'];
    // doctorName = json['name'];
    doctorGender = json['gender'];
    providerUri = json['providerUri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['doctorAbhaAddress'] = this.doctorAbhaAddress;
    data['patientAbhaAddress'] = this.patientAbhaAddress;
    // data['doctorName'] = this.doctorName;
    data['doctorGender'] = this.doctorGender;
    data['providerUri'] = this.providerUri;
    return data;
  }
}
