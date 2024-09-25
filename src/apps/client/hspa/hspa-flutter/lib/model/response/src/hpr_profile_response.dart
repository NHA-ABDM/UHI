class HPRProfileResponse {
  int? referenceNumber;
  Practitioner? practitioner;
  String? message;

  HPRProfileResponse({this.referenceNumber, this.practitioner, this.message});

  HPRProfileResponse.fromJson(Map<String, dynamic> json) {
    referenceNumber = json['referenceNumber'];
    practitioner = json['practitioner'] != null
        ? Practitioner.fromJson(json['practitioner'])
        : null;
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referenceNumber'] = referenceNumber;
    if (practitioner != null) {
      data['practitioner'] = practitioner!.toJson();
    }
    data['Message'] = message;
    return data;
  }
}

class Practitioner {
  String? id;
  String? active;
  String? name;
  String? gender;
  String? profilePhoto;
  String? hprType;
  String? email;
  String? mobileNumber;
  String? dateOfBirth;
  Address? address;
  //List<Null>? visaDetails;
  List<Qualifications1>? qualifications1;
  List<HbiDetails>? hbiDetails;

  Practitioner(
      {this.id,
        this.active,
        this.name,
        this.gender,
        this.profilePhoto,
        this.hprType,
        this.email,
        this.mobileNumber,
        this.dateOfBirth,
        this.address,
        //this.visaDetails,
        this.qualifications1,
        this.hbiDetails});

  Practitioner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    active = json['active'];
    name = json['name'];
    gender = json['gender'];
    profilePhoto = json['profile_photo'];
    hprType = json['hpr_type'];
    email = json['email'];
    mobileNumber = json['mobileNumber'];
    dateOfBirth = json['dateOfBirth'];
    address =
    json['address'] != null ? Address.fromJson(json['address']) : null;
    /*if (json['visaDetails'] != null) {
      visaDetails = <Null>[];
      json['visaDetails'].forEach((v) {
        visaDetails!.add(new Null.fromJson(v));
      });
    }*/
    if (json['qualifications1'] != null) {
      qualifications1 = <Qualifications1>[];
      json['qualifications1'].forEach((v) {
        qualifications1!.add(Qualifications1.fromJson(v));
      });
    }
    if (json['hbiDetails'] != null) {
      hbiDetails = <HbiDetails>[];
      json['hbiDetails'].forEach((v) {
        hbiDetails!.add(HbiDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['active'] = active;
    data['name'] = name;
    data['gender'] = gender;
    data['profile_photo'] = profilePhoto;
    data['hpr_type'] = hprType;
    data['email'] = email;
    data['mobileNumber'] = mobileNumber;
    data['dateOfBirth'] = dateOfBirth;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    /*if (this.visaDetails != null) {
      data['visaDetails'] = this.visaDetails!.map((v) => v.toJson()).toList();
    }*/
    if (qualifications1 != null) {
      data['qualifications1'] =
          qualifications1!.map((v) => v.toJson()).toList();
    }
    if (hbiDetails != null) {
      data['hbiDetails'] = hbiDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Address {
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? district;
  String? country;

  Address(
      {this.addressLine1,
        this.addressLine2,
        this.city,
        this.state,
        this.district,
        this.country});

  Address.fromJson(Map<String, dynamic> json) {
    addressLine1 = json['addressLine1'];
    addressLine2 = json['addressLine2'];
    city = json['city'];
    state = json['state'];
    district = json['district'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['addressLine1'] = addressLine1;
    data['addressLine2'] = addressLine2;
    data['city'] = city;
    data['state'] = state;
    data['district'] = district;
    data['country'] = country;
    return data;
  }
}

class Qualifications1 {
  int? identifier;
  String? courseName;
  String? collegeName;
  String? universityName;
  String? qualificationYear;
  String? qualificationMonth;

  Qualifications1(
      {this.identifier,
        this.courseName,
        this.collegeName,
        this.universityName,
        this.qualificationYear,
        this.qualificationMonth});

  Qualifications1.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    courseName = json['courseName'];
    collegeName = json['collegeName'];
    universityName = json['universityName'];
    qualificationYear = json['qualificationYear'];
    qualificationMonth = json['qualificationMonth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['courseName'] = courseName;
    data['collegeName'] = collegeName;
    data['universityName'] = universityName;
    data['qualificationYear'] = qualificationYear;
    data['qualificationMonth'] = qualificationMonth;
    return data;
  }
}

class HbiDetails {
  int? identifier;
  String? languageKnown;
  String? languageKnownIds;
  String? preferredCountries;
  String? preferredCountriesIds;
  String? qualifierExams;
  String? selectedExams;
  CertificateUrl? certificateUrl;
  String? availabilityFrom;
  String? availabilityTo;
  String? score;
  String? passportNo;
  String? passportIssueDate;
  String? passportExpirationDate;
  String? nationality;
  bool? visaAvailable;
  String? weoiExperience;
  String? weoiCountryId;
  String? weoiNameFacility;
  String? weoiRelevingExperienceLetter;
  String? otherRemarks;
  bool? decalaration;

  HbiDetails(
      {this.identifier,
        this.languageKnown,
        this.languageKnownIds,
        this.preferredCountries,
        this.preferredCountriesIds,
        this.qualifierExams,
        this.selectedExams,
        this.certificateUrl,
        this.availabilityFrom,
        this.availabilityTo,
        this.score,
        this.passportNo,
        this.passportIssueDate,
        this.passportExpirationDate,
        this.nationality,
        this.visaAvailable,
        this.weoiExperience,
        this.weoiCountryId,
        this.weoiNameFacility,
        this.weoiRelevingExperienceLetter,
        this.otherRemarks,
        this.decalaration});

  HbiDetails.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    languageKnown = json['languageKnown'];
    languageKnownIds = json['languageKnownIds'];
    preferredCountries = json['preferredCountries'];
    preferredCountriesIds = json['preferredCountriesIds'];
    qualifierExams = json['qualifierExams'];
    selectedExams = json['selectedExams'];
    certificateUrl = json['certificateUrl'] != null
        ? CertificateUrl.fromJson(json['certificateUrl'])
        : null;
    availabilityFrom = json['availabilityFrom'];
    availabilityTo = json['availabilityTo'];
    score = json['score'];
    passportNo = json['passportNo'];
    passportIssueDate = json['passportIssueDate'];
    passportExpirationDate = json['passportExpirationDate'];
    nationality = json['nationality'];
    visaAvailable = json['visaAvailable'];
    weoiExperience = json['weoiExperience'];
    weoiCountryId = json['weoiCountryId'];
    weoiNameFacility = json['weoiNameFacility'];
    weoiRelevingExperienceLetter = json['weoiRelevingExperienceLetter'];
    otherRemarks = json['otherRemarks'];
    decalaration = json['decalaration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['languageKnown'] = languageKnown;
    data['languageKnownIds'] = languageKnownIds;
    data['preferredCountries'] = preferredCountries;
    data['preferredCountriesIds'] = preferredCountriesIds;
    data['qualifierExams'] = qualifierExams;
    data['selectedExams'] = selectedExams;
    if (certificateUrl != null) {
      data['certificateUrl'] = certificateUrl!.toJson();
    }
    data['availabilityFrom'] = availabilityFrom;
    data['availabilityTo'] = availabilityTo;
    data['score'] = score;
    data['passportNo'] = passportNo;
    data['passportIssueDate'] = passportIssueDate;
    data['passportExpirationDate'] = passportExpirationDate;
    data['nationality'] = nationality;
    data['visaAvailable'] = visaAvailable;
    data['weoiExperience'] = weoiExperience;
    data['weoiCountryId'] = weoiCountryId;
    data['weoiNameFacility'] = weoiNameFacility;
    data['weoiRelevingExperienceLetter'] = weoiRelevingExperienceLetter;
    data['otherRemarks'] = otherRemarks;
    data['decalaration'] = decalaration;
    return data;
  }
}

class CertificateUrl {
  String? s1;
  String? s9;
  String? s14;

  CertificateUrl({this.s1, this.s9, this.s14});

  CertificateUrl.fromJson(Map<String, dynamic> json) {
    s1 = json['1'];
    s9 = json['9'];
    s14 = json['14'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['1'] = s1;
    data['9'] = s9;
    data['14'] = s14;
    return data;
  }
}
