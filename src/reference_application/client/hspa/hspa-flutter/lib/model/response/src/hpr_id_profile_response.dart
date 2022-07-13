class HPRIDProfileResponse {
  String? hprIdNumber;
  String? hprId;
  String? mobile;
  String? firstName;
  String? middleName;
  String? lastName;
  String? name;
  String? yearOfBirth;
  String? dayOfBirth;
  String? monthOfBirth;
  String? gender;
  String? email;
  String? profilePhoto;
  String? stateCode;
  String? districtCode;
  String? subDistrictCode;
  String? villageCode;
  String? townCode;
  String? wardCode;
  String? pinCode;
  String? address;
  String? kycPhoto;
  String? stateName;
  String? districtName;
  String? subDistrictName;
  String? villageName;
  String? townName;
  String? wardName;
  List<String>? authMethods;
  bool? kycVerified;
  dynamic verificationType;
  dynamic verificationStatus;
  int? categoryId;
  String? categoryName;
  int? categorySubId;
  String? categorySubName;
  bool? emailVerified;
  bool? newData;
  //Categories? categories;

  HPRIDProfileResponse({
    this.hprIdNumber,
    this.hprId,
    this.mobile,
    this.firstName,
    this.middleName,
    this.lastName,
    this.name,
    this.yearOfBirth,
    this.dayOfBirth,
    this.monthOfBirth,
    this.gender,
    this.email,
    this.profilePhoto,
    this.stateCode,
    this.districtCode,
    this.subDistrictCode,
    this.villageCode,
    this.townCode,
    this.wardCode,
    this.pinCode,
    this.address,
    this.kycPhoto,
    this.stateName,
    this.districtName,
    this.subDistrictName,
    this.villageName,
    this.townName,
    this.wardName,
    this.authMethods,
    this.kycVerified,
    this.verificationType,
    this.verificationStatus,
    this.categoryId,
    this.categoryName,
    this.categorySubId,
    this.categorySubName,
    this.emailVerified,
    this.newData,
    //this.categories,
  });

  HPRIDProfileResponse.fromJson(Map<String, dynamic> json) {
    hprIdNumber = json['hprIdNumber'];
    hprId = json['hprId'];
    mobile = json['mobile'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    name = json['name'];
    yearOfBirth = json['yearOfBirth'];
    dayOfBirth = json['dayOfBirth'];
    monthOfBirth = json['monthOfBirth'];
    gender = json['gender'];
    email = json['email'];
    profilePhoto = json['profilePhoto'];
    stateCode = json['stateCode'];
    districtCode = json['districtCode'];
    subDistrictCode = json['subDistrictCode'];
    villageCode = json['villageCode'];
    townCode = json['townCode'];
    wardCode = json['wardCode'];
    pinCode = json['pincode'];
    address = json['address'];
    kycPhoto = json['kycPhoto'];
    stateName = json['stateName'];
    districtName = json['districtName'];
    subDistrictName = json['subdistrictName'];
    villageName = json['villageName'];
    townName = json['townName'];
    wardName = json['wardName'];
    authMethods = json['authMethods'].cast<String>();
    kycVerified = json['kycVerified'];
    verificationType = json['verificationType'];
    verificationStatus = json['verificationStatus'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    categorySubId = json['categorySubId'];
    categorySubName = json['categorySubName'];
    emailVerified = json['emailVerified'];
    newData = json['new'];
    /*categories = json['categories'] != null
        ? Categories.fromJson(json['categories'])
        : null;*/
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hprIdNumber'] = hprIdNumber;
    data['hprId'] = hprId;
    data['mobile'] = mobile;
    data['firstName'] = firstName;
    data['middleName'] = middleName;
    data['lastName'] = lastName;
    data['name'] = name;
    data['yearOfBirth'] = yearOfBirth;
    data['dayOfBirth'] = dayOfBirth;
    data['monthOfBirth'] = monthOfBirth;
    data['gender'] = gender;
    data['email'] = email;
    data['profilePhoto'] = profilePhoto;
    data['stateCode'] = stateCode;
    data['districtCode'] = districtCode;
    data['subDistrictCode'] = subDistrictCode;
    data['villageCode'] = villageCode;
    data['townCode'] = townCode;
    data['wardCode'] = wardCode;
    data['pincode'] = pinCode;
    data['address'] = address;
    data['kycPhoto'] = kycPhoto;
    data['stateName'] = stateName;
    data['districtName'] = districtName;
    data['subdistrictName'] = subDistrictName;
    data['villageName'] = villageName;
    data['townName'] = townName;
    data['wardName'] = wardName;
    data['authMethods'] = authMethods;
    data['kycVerified'] = kycVerified;
    data['verificationType'] = verificationType;
    data['verificationStatus'] = verificationStatus;
    data['categoryId'] = categoryId;
    data['categoryName'] = categoryName;
    data['categorySubId'] = categorySubId;
    data['categorySubName'] = categorySubName;
    data['emailVerified'] = emailVerified;
    data['new'] = newData;
    /*if (categories != null) {
      data['categories'] = categories!.toJson();
    }*/
    return data;
  }
}

/*class Categories {


  Categories

  (

  {
});

Categories.fromJson(

Map<String, dynamic> json
) {
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  return data;
}}*/
