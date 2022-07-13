class RegistrationRequestModel {
  String? address;
  String? countryCode;
  RegistrationDateOfBirth? dateOfBirth;
  String? districtCode;
  String? email;
  String? gender;
  String? mobile;
  RegistrationName? name;
  String? pinCode;
  String? sessionId;
  String? stateCode;

  RegistrationRequestModel(
      {this.address,
      this.countryCode,
      this.dateOfBirth,
      this.districtCode,
      this.email,
      this.gender,
      this.mobile,
      this.name,
      this.pinCode,
      this.sessionId,
      this.stateCode});

  RegistrationRequestModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    countryCode = json['countryCode'];
    dateOfBirth = json['dateOfBirth'] != null
        ? new RegistrationDateOfBirth.fromJson(json['dateOfBirth'])
        : null;
    districtCode = json['districtCode'];
    email = json['email'];
    gender = json['gender'];
    mobile = json['mobile'];
    name = json['name'] != null
        ? new RegistrationName.fromJson(json['name'])
        : null;
    pinCode = json['pinCode'];
    sessionId = json['sessionId'];
    stateCode = json['stateCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['countryCode'] = this.countryCode;
    if (this.dateOfBirth != null) {
      data['dateOfBirth'] = this.dateOfBirth!.toJson();
    }
    data['districtCode'] = this.districtCode;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['mobile'] = this.mobile;
    if (this.name != null) {
      data['name'] = this.name!.toJson();
    }
    data['pinCode'] = this.pinCode;
    data['sessionId'] = this.sessionId;
    data['stateCode'] = this.stateCode;
    return data;
  }
}

class RegistrationDateOfBirth {
  int? date;
  int? month;
  int? year;

  RegistrationDateOfBirth({this.date, this.month, this.year});

  RegistrationDateOfBirth.fromJson(Map<String, dynamic> json) {
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

class RegistrationName {
  String? first;
  String? last;
  String? middle;

  RegistrationName({this.first, this.last, this.middle});

  RegistrationName.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    middle = json['middle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.first;
    data['last'] = this.last;
    data['middle'] = this.middle;
    return data;
  }
}
