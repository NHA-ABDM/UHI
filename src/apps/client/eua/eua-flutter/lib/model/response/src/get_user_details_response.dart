class GetUserDetailsResponse {
  String? id;
  String? fullName;
  Name? name;
  String? gender;
  DateOfBirth? dateOfBirth;
  bool? hasTransactionPin;
  String? healthId;
  String? address;
  String? stateName;
  String? stateCode;
  String? districtName;
  String? districtCode;
  bool? aadhaarVerified;
  String? profilePhoto;
  String? kycDocumentType;
  String? kycStatus;
  String? mobile;
  bool? mobileVerified;
  String? email;
  bool? emailVerified;
  String? countryName;
  String? pincode;

  GetUserDetailsResponse(
      {this.id,
      this.fullName,
      this.name,
      this.gender,
      this.dateOfBirth,
      this.hasTransactionPin,
      this.healthId,
      this.address,
      this.stateName,
      this.stateCode,
      this.districtName,
      this.districtCode,
      this.aadhaarVerified,
      this.profilePhoto,
      this.kycDocumentType,
      this.kycStatus,
      this.mobile,
      this.mobileVerified,
      this.email,
      this.emailVerified,
      this.countryName,
      this.pincode});

  GetUserDetailsResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    name = json['name'] != null ? new Name.fromJson(json['name']) : null;
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'] != null
        ? new DateOfBirth.fromJson(json['dateOfBirth'])
        : null;
    hasTransactionPin = json['hasTransactionPin'];
    healthId = json['healthId'];
    address = json['address'];
    stateName = json['stateName'];
    stateCode = json['stateCode'];
    districtName = json['districtName'];
    districtCode = json['districtCode'];
    aadhaarVerified = json['aadhaarVerified'];
    profilePhoto = json['profilePhoto'];
    kycDocumentType = json['kycDocumentType'];
    kycStatus = json['kycStatus'];
    mobile = json['mobile'];
    mobileVerified = json['mobileVerified'];
    email = json['email'];
    emailVerified = json['emailVerified'];
    countryName = json['countryName'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    if (this.name != null) {
      data['name'] = this.name!.toJson();
    }
    data['gender'] = this.gender;
    if (this.dateOfBirth != null) {
      data['dateOfBirth'] = this.dateOfBirth!.toJson();
    }
    data['hasTransactionPin'] = this.hasTransactionPin;
    data['healthId'] = this.healthId;
    data['address'] = this.address;
    data['stateName'] = this.stateName;
    data['stateCode'] = this.stateCode;
    data['districtName'] = this.districtName;
    data['districtCode'] = this.districtCode;
    data['aadhaarVerified'] = this.aadhaarVerified;
    data['profilePhoto'] = this.profilePhoto;
    data['kycDocumentType'] = this.kycDocumentType;
    data['kycStatus'] = this.kycStatus;
    data['mobile'] = this.mobile;
    data['mobileVerified'] = this.mobileVerified;
    data['email'] = this.email;
    data['emailVerified'] = this.emailVerified;
    data['countryName'] = this.countryName;
    data['pincode'] = this.pincode;
    return data;
  }
}

class Name {
  String? first;
  String? middle;
  String? last;

  Name({this.first, this.middle, this.last});

  Name.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    middle = json['middle'];
    last = json['last'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.first;
    data['middle'] = this.middle;
    data['last'] = this.last;
    return data;
  }
}

class DateOfBirth {
  int? date;
  int? month;
  int? year;

  DateOfBirth({this.date, this.month, this.year});

  DateOfBirth.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    month = json['month'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['month'] = this.month;
    data['year'] = this.year;
    return data;
  }
}
