class RegistrationOtpResponseModel {
  String? sessionId;
  List<String>? mappedPhrAddress;

  RegistrationOtpResponseModel({this.sessionId, this.mappedPhrAddress});

  RegistrationOtpResponseModel.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    mappedPhrAddress = json['mappedPhrAddress'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    if (this.mappedPhrAddress != null || this.mappedPhrAddress!.isNotEmpty) {
      data['mappedPhrAddress'] = this.mappedPhrAddress;
    }
    return data;
  }
}
