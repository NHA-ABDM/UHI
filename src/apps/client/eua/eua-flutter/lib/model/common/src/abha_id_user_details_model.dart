class AbhaIdUserDetailsModel {
  int? aadhaar;
  String? birthdate;
  String? careOf;
  String? district;
  String? email;
  String? gender;
  String? healthIdNumber;
  String? house;
  JwtResponse? jwtResponse;
  String? landmark;
  String? locality;
  String? name;
  int? phone;
  String? photo;
  int? pincode;
  String? postOffice;
  String? state;
  String? street;
  String? subDist;
  String? txnId;
  String? villageTownCity;

  AbhaIdUserDetailsModel(
      {this.aadhaar,
      this.birthdate,
      this.careOf,
      this.district,
      this.email,
      this.gender,
      this.healthIdNumber,
      this.house,
      this.jwtResponse,
      this.landmark,
      this.locality,
      this.name,
      this.phone,
      this.photo,
      this.pincode,
      this.postOffice,
      this.state,
      this.street,
      this.subDist,
      this.txnId,
      this.villageTownCity});

  AbhaIdUserDetailsModel.fromJson(Map<String, dynamic> json) {
    aadhaar = json['aadhaar'];
    birthdate = json['birthdate'];
    careOf = json['careOf'];
    district = json['district'];
    email = json['email'];
    gender = json['gender'];
    healthIdNumber = json['healthIdNumber'];
    house = json['house'];
    jwtResponse = json['jwtResponse'] != null
        ? new JwtResponse.fromJson(json['jwtResponse'])
        : null;
    landmark = json['landmark'];
    locality = json['locality'];
    name = json['name'];
    phone = json['phone'];
    photo = json['photo'];
    pincode = json['pincode'];
    postOffice = json['postOffice'];
    state = json['state'];
    street = json['street'];
    subDist = json['subDist'];
    txnId = json['txnId'];
    villageTownCity = json['villageTownCity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aadhaar'] = this.aadhaar;
    data['birthdate'] = this.birthdate;
    data['careOf'] = this.careOf;
    data['district'] = this.district;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['healthIdNumber'] = this.healthIdNumber;
    data['house'] = this.house;
    if (this.jwtResponse != null) {
      data['jwtResponse'] = this.jwtResponse!.toJson();
    }
    data['landmark'] = this.landmark;
    data['locality'] = this.locality;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['photo'] = this.photo;
    data['pincode'] = this.pincode;
    data['postOffice'] = this.postOffice;
    data['state'] = this.state;
    data['street'] = this.street;
    data['subDist'] = this.subDist;
    data['txnId'] = this.txnId;
    data['villageTownCity'] = this.villageTownCity;
    return data;
  }
}

class JwtResponse {
  int? expiresIn;
  int? refreshExpiresIn;
  String? refreshToken;
  String? token;

  JwtResponse(
      {this.expiresIn, this.refreshExpiresIn, this.refreshToken, this.token});

  JwtResponse.fromJson(Map<String, dynamic> json) {
    expiresIn = json['expiresIn'];
    refreshExpiresIn = json['refreshExpiresIn'];
    refreshToken = json['refreshToken'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['expiresIn'] = this.expiresIn;
    data['refreshExpiresIn'] = this.refreshExpiresIn;
    data['refreshToken'] = this.refreshToken;
    data['token'] = this.token;
    return data;
  }
}
