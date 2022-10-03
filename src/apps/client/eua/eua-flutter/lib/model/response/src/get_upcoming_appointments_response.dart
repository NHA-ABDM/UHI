class UpcomingAppointmentResponseModal {
  String? orderId;
  String? categoryId;
  String? orderDate;
  String? healthcareServiceName;
  String? healthcareServiceId;
  String? healthcareProviderName;
  String? healthcareProviderId;
  String? healthcareProviderUrl;
  String? healthcareServiceProviderEmail;
  String? healthcareServiceProviderPhone;
  String? healthcareProfessionalName;
  String? healthcareProfessionalImage;
  String? healthcareProfessionalEmail;
  String? healthcareProfessionalPhone;
  String? healthcareProfessionalId;
  String? healthcareProfessionalGender;
  String? serviceFulfillmentStartTime;
  String? serviceFulfillmentEndTime;
  String? serviceFulfillmentType;
  String? symptoms;
  String? languagesSpokenByHealthcareProfessional;
  String? healthcareProfessionalExperience;
  String? isServiceFulfilled;
  String? transId;
  String? primaryDoctor;
  String? secondaryDoctor;
  String? groupConsultStatus;
  String? healthcareProfessionalDepartment;
  String? message;
  String? slotId;
  String? user;
  String? abhaId;
  // String? payment;
  AppointmentPayment? payment;

  UpcomingAppointmentResponseModal(
      {this.orderId,
      this.categoryId,
      this.orderDate,
      this.healthcareServiceName,
      this.healthcareServiceId,
      this.healthcareProviderName,
      this.healthcareProviderId,
      this.healthcareProviderUrl,
      this.healthcareServiceProviderEmail,
      this.healthcareServiceProviderPhone,
      this.healthcareProfessionalName,
      this.healthcareProfessionalImage,
      this.healthcareProfessionalEmail,
      this.healthcareProfessionalPhone,
      this.healthcareProfessionalId,
      this.healthcareProfessionalGender,
      this.serviceFulfillmentStartTime,
      this.serviceFulfillmentEndTime,
      this.serviceFulfillmentType,
      this.symptoms,
      this.languagesSpokenByHealthcareProfessional,
      this.healthcareProfessionalExperience,
      this.isServiceFulfilled,
      this.transId,
      this.primaryDoctor,
      this.secondaryDoctor,
      this.groupConsultStatus,
      this.healthcareProfessionalDepartment,
      this.message,
      this.slotId,
      this.user,
      this.abhaId,
      this.payment});

  UpcomingAppointmentResponseModal.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    categoryId = json['categoryId'];
    orderDate = json['orderDate'];
    healthcareServiceName = json['healthcareServiceName'];
    healthcareServiceId = json['healthcareServiceId'];
    healthcareProviderName = json['healthcareProviderName'];
    healthcareProviderId = json['healthcareProviderId'];
    healthcareProviderUrl = json['healthcareProviderUrl'];
    healthcareServiceProviderEmail = json['healthcareServiceProviderEmail'];
    healthcareServiceProviderPhone = json['healthcareServiceProviderPhone'];
    healthcareProfessionalName = json['healthcareProfessionalName'];
    healthcareProfessionalImage = json['healthcareProfessionalImage'];
    healthcareProfessionalEmail = json['healthcareProfessionalEmail'];
    healthcareProfessionalPhone = json['healthcareProfessionalPhone'];
    healthcareProfessionalId = json['healthcareProfessionalId'];
    healthcareProfessionalGender = json['healthcareProfessionalGender'];
    serviceFulfillmentStartTime = json['serviceFulfillmentStartTime'];
    serviceFulfillmentEndTime = json['serviceFulfillmentEndTime'];
    serviceFulfillmentType = json['serviceFulfillmentType'];
    symptoms = json['symptoms'];
    languagesSpokenByHealthcareProfessional =
        json['languagesSpokenByHealthcareProfessional'];
    healthcareProfessionalExperience = json['healthcareProfessionalExperience'];
    isServiceFulfilled = json['isServiceFulfilled'];
    transId = json['transId'];
    primaryDoctor = json['primaryDoctor'];
    secondaryDoctor = json['secondaryDoctor'];
    groupConsultStatus = json['groupConsultStatus'];
    healthcareProfessionalDepartment = json['healthcareProfessionalDepartment'];
    message = json['message'];
    slotId = json['slotId'];
    user = json['user'];
    abhaId = json['abhaId'];
    payment = json['payment'] != null
        ? new AppointmentPayment.fromJson(json['payment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['categoryId'] = this.categoryId;
    data['orderDate'] = this.orderDate;
    data['healthcareServiceName'] = this.healthcareServiceName;
    data['healthcareServiceId'] = this.healthcareServiceId;
    data['healthcareProviderName'] = this.healthcareProviderName;
    data['healthcareProviderId'] = this.healthcareProviderId;
    data['healthcareProviderUrl'] = this.healthcareProviderUrl;
    data['healthcareServiceProviderEmail'] =
        this.healthcareServiceProviderEmail;
    data['healthcareServiceProviderPhone'] =
        this.healthcareServiceProviderPhone;
    data['healthcareProfessionalName'] = this.healthcareProfessionalName;
    data['healthcareProfessionalImage'] = this.healthcareProfessionalImage;
    data['healthcareProfessionalEmail'] = this.healthcareProfessionalEmail;
    data['healthcareProfessionalPhone'] = this.healthcareProfessionalPhone;
    data['healthcareProfessionalId'] = this.healthcareProfessionalId;
    data['healthcareProfessionalGender'] = this.healthcareProfessionalGender;
    data['serviceFulfillmentStartTime'] = this.serviceFulfillmentStartTime;
    data['serviceFulfillmentEndTime'] = this.serviceFulfillmentEndTime;
    data['serviceFulfillmentType'] = this.serviceFulfillmentType;
    data['symptoms'] = this.symptoms;
    data['languagesSpokenByHealthcareProfessional'] =
        this.languagesSpokenByHealthcareProfessional;
    data['healthcareProfessionalExperience'] =
        this.healthcareProfessionalExperience;
    data['isServiceFulfilled'] = this.isServiceFulfilled;
    data['transId'] = this.transId;
    data['primaryDoctor'] = this.primaryDoctor;
    data['secondaryDoctor'] = this.secondaryDoctor;
    data['groupConsultStatus'] = this.groupConsultStatus;
    data['healthcareProfessionalDepartment'] =
        this.healthcareProfessionalDepartment;
    data['message'] = this.message;
    data['slotId'] = this.slotId;
    data['user'] = this.user;
    data['abhaId'] = this.abhaId;
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    return data;
  }
}

class AppointmentPayment {
  String? transactionId;
  String? method;
  String? currency;
  String? transactionTimestamp;
  String? consultationCharge;
  String? phrHandlingFees;
  String? sgst;
  String? cgst;
  String? transactionState;
  String? user;
  String? userAbhaId;

  AppointmentPayment(
      {this.transactionId,
      this.method,
      this.currency,
      this.transactionTimestamp,
      this.consultationCharge,
      this.phrHandlingFees,
      this.sgst,
      this.cgst,
      this.transactionState,
      this.user,
      this.userAbhaId});

  AppointmentPayment.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'];
    method = json['method'];
    currency = json['currency'];
    transactionTimestamp = json['transactionTimestamp'];
    consultationCharge = json['consultationCharge'];
    phrHandlingFees = json['phrHandlingFees'];
    sgst = json['sgst'];
    cgst = json['cgst'];
    transactionState = json['transactionState'];
    user = json['user'];
    userAbhaId = json['userAbhaId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionId'] = this.transactionId;
    data['method'] = this.method;
    data['currency'] = this.currency;
    data['transactionTimestamp'] = this.transactionTimestamp;
    data['consultationCharge'] = this.consultationCharge;
    data['phrHandlingFees'] = this.phrHandlingFees;
    data['sgst'] = this.sgst;
    data['cgst'] = this.cgst;
    data['transactionState'] = this.transactionState;
    data['user'] = this.user;
    data['userAbhaId'] = this.userAbhaId;
    return data;
  }
}
