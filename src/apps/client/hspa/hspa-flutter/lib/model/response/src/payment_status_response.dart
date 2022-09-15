class PaymentStatusResponse {
  List<PaymentStatus>? paymentStatusList;

  PaymentStatusResponse({this.paymentStatusList});

  PaymentStatusResponse.fromJson(List<dynamic> json) {
    if (json.isNotEmpty) {
      paymentStatusList = <PaymentStatus>[];
      for (Map<String, dynamic> map in json) {
        paymentStatusList!.add(PaymentStatus.fromJson(map));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (paymentStatusList != null) {
      data['results'] = paymentStatusList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentStatus {
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
  String? healthcareProfessionalDepartment;
  String? message;
  String? slotId;
  String? abhaId;
  String? patientName;
  Payment? payment;

  PaymentStatus(
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
        this.healthcareProfessionalDepartment,
        this.message,
        this.slotId,
        this.abhaId,
        this.patientName,
        this.payment});

  PaymentStatus.fromJson(Map<String, dynamic> json) {
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
    healthcareProfessionalDepartment = json['healthcareProfessionalDepartment'];
    message = json['message'];
    slotId = json['slotId'];
    abhaId = json['abhaId'];
    patientName = json['patientName'];
    payment =
    json['payment'] != null ? Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['categoryId'] = categoryId;
    data['orderDate'] = orderDate;
    data['healthcareServiceName'] = healthcareServiceName;
    data['healthcareServiceId'] = healthcareServiceId;
    data['healthcareProviderName'] = healthcareProviderName;
    data['healthcareProviderId'] = healthcareProviderId;
    data['healthcareProviderUrl'] = healthcareProviderUrl;
    data['healthcareServiceProviderEmail'] =
        healthcareServiceProviderEmail;
    data['healthcareServiceProviderPhone'] =
        healthcareServiceProviderPhone;
    data['healthcareProfessionalName'] = healthcareProfessionalName;
    data['healthcareProfessionalImage'] = healthcareProfessionalImage;
    data['healthcareProfessionalEmail'] = healthcareProfessionalEmail;
    data['healthcareProfessionalPhone'] = healthcareProfessionalPhone;
    data['healthcareProfessionalId'] = healthcareProfessionalId;
    data['healthcareProfessionalGender'] = healthcareProfessionalGender;
    data['serviceFulfillmentStartTime'] = serviceFulfillmentStartTime;
    data['serviceFulfillmentEndTime'] = serviceFulfillmentEndTime;
    data['serviceFulfillmentType'] = serviceFulfillmentType;
    data['symptoms'] = symptoms;
    data['languagesSpokenByHealthcareProfessional'] =
        languagesSpokenByHealthcareProfessional;
    data['healthcareProfessionalExperience'] =
        healthcareProfessionalExperience;
    data['isServiceFulfilled'] = isServiceFulfilled;
    data['healthcareProfessionalDepartment'] =
        healthcareProfessionalDepartment;
    data['message'] = message;
    data['slotId'] = slotId;
    data['abhaId'] = abhaId;
    data['patientName'] = patientName;
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    return data;
  }
}

class Payment {
  String? transactionId;
  String? method;
  String? currency;
  String? transactionTimestamp;
  String? consultationCharge;
  String? phrHandlingFees;
  String? sgst;
  String? cgst;
  String? transactionState;
  String? userAbhaId;

  Payment(
      {this.transactionId,
        this.method,
        this.currency,
        this.transactionTimestamp,
        this.consultationCharge,
        this.phrHandlingFees,
        this.sgst,
        this.cgst,
        this.transactionState,
        this.userAbhaId});

  Payment.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'];
    method = json['method'];
    currency = json['currency'];
    transactionTimestamp = json['transactionTimestamp'];
    consultationCharge = json['consultationCharge'];
    phrHandlingFees = json['phrHandlingFees'];
    sgst = json['sgst'];
    cgst = json['cgst'];
    transactionState = json['transactionState'];
    userAbhaId = json['userAbhaId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionId'] = transactionId;
    data['method'] = method;
    data['currency'] = currency;
    data['transactionTimestamp'] = transactionTimestamp;
    data['consultationCharge'] = consultationCharge;
    data['phrHandlingFees'] = phrHandlingFees;
    data['sgst'] = sgst;
    data['cgst'] = cgst;
    data['transactionState'] = transactionState;
    data['userAbhaId'] = userAbhaId;
    return data;
  }
}
