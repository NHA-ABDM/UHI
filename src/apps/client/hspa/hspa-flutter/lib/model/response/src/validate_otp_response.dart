class ValidateOTPResponse {
  String? txnId;
  String? token;
  List<MobileLinkedHpIdDTO>? mobileLinkedHpIdDTO;

  ValidateOTPResponse({this.txnId, this.token, this.mobileLinkedHpIdDTO});

  ValidateOTPResponse.fromJson(Map<String, dynamic> json) {
    txnId = json['txnId'];
    token = json['token'];
    if (json['mobileLinkedHpIdDTO'] != null) {
      mobileLinkedHpIdDTO = <MobileLinkedHpIdDTO>[];
      json['mobileLinkedHpIdDTO'].forEach((v) {
        mobileLinkedHpIdDTO!.add(MobileLinkedHpIdDTO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['txnId'] = txnId;
    data['token'] = token;
    if (mobileLinkedHpIdDTO != null) {
      data['mobileLinkedHpIdDTO'] =
          mobileLinkedHpIdDTO!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MobileLinkedHpIdDTO {
  String? hprIdNumber;

  MobileLinkedHpIdDTO({this.hprIdNumber});

  MobileLinkedHpIdDTO.fromJson(Map<String, dynamic> json) {
    hprIdNumber = json['hprIdNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hprIdNumber'] = hprIdNumber;
    return data;
  }
}
