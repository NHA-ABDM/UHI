class HSPAAppointmentsResponse {
   List<HSPAAppointments>? listHSPAAppointments;

   HSPAAppointmentsResponse({this.listHSPAAppointments});

   HSPAAppointmentsResponse.fromJson(List<dynamic> json) {
     if(json.isNotEmpty) {
       listHSPAAppointments = <HSPAAppointments>[];
       for (Map<String, dynamic> map in json) {
         listHSPAAppointments!.add(HSPAAppointments.fromJson(map));
       }
     }
   }
}

class HSPAAppointments {
  String? orderId;
  String? categoryId;
  String? appointmentId;
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
  String? transId;
  String? primaryDoctor;
  String? secondaryDoctor;
  bool? groupConsultStatus;
  String? abhaId;
  String? patientName;
  String? patientGender;
  String? patientConsumerUri;
  String? primaryDoctorName;
  String? primaryDoctorHprAddress;
  String? primaryDoctorGender;
  String? primaryDoctorProviderUri;
  String? secondaryDoctorName;
  String? secondaryDoctorHprAddress;
  String? secondaryDoctorGender;
  String? secondaryDoctorProviderUri;

  Payment? payment;

  HSPAAppointments(
      {this.orderId,
        this.categoryId,
        this.appointmentId,
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
        this.transId,
        this.primaryDoctor,
        this.secondaryDoctor,
        this.groupConsultStatus,
        this.abhaId,
        this.patientName,
        this.patientGender,
        this.patientConsumerUri,
        this.primaryDoctorName,
        this.primaryDoctorHprAddress,
        this.primaryDoctorGender,
        this.primaryDoctorProviderUri,
        this.secondaryDoctorName,
        this.secondaryDoctorHprAddress,
        this.secondaryDoctorGender,
        this.secondaryDoctorProviderUri,
        this.payment});

  HSPAAppointments.fromJson(Map<String, dynamic> json) {
    if(json.containsKey('orderId')) {
      orderId = json['orderId'];
    }
    if(json.containsKey('categoryId')) {
      categoryId = json['categoryId'];
    }
    if(json.containsKey('appointmentId')) {
      appointmentId = json['appointmentId'];
    }
    if(json.containsKey('orderDate')) {
      orderDate = json['orderDate'];
    }
    if(json.containsKey('healthcareServiceName')) {
      healthcareServiceName = json['healthcareServiceName'];
    }
    if(json.containsKey('healthcareServiceId')) {
      healthcareServiceId = json['healthcareServiceId'];
    }
    if(json.containsKey('healthcareProviderName')) {
      healthcareProviderName = json['healthcareProviderName'];
    }
    if(json.containsKey('healthcareProviderId')) {
      healthcareProviderId = json['healthcareProviderId'];
    }
    if(json.containsKey('healthcareProviderUrl')) {
      healthcareProviderUrl = json['healthcareProviderUrl'];
    }
    if(json.containsKey('healthcareServiceProviderEmail')) {
      healthcareServiceProviderEmail = json['healthcareServiceProviderEmail'];
    }
    if(json.containsKey('healthcareServiceProviderPhone')) {
      healthcareServiceProviderPhone = json['healthcareServiceProviderPhone'];
    }
    if(json.containsKey('healthcareProfessionalName')) {
      healthcareProfessionalName = json['healthcareProfessionalName'];
    }
    if(json.containsKey('healthcareProfessionalImage')) {
      healthcareProfessionalImage = json['healthcareProfessionalImage'];
    }
    if(json.containsKey('healthcareProfessionalEmail')) {
      healthcareProfessionalEmail = json['healthcareProfessionalEmail'];
    }
    if(json.containsKey('healthcareProfessionalPhone')) {
      healthcareProfessionalPhone = json['healthcareProfessionalPhone'];
    }
    if(json.containsKey('healthcareProfessionalId')) {
      healthcareProfessionalId = json['healthcareProfessionalId'];
    }
    if(json.containsKey('healthcareProfessionalGender')) {
      healthcareProfessionalGender = json['healthcareProfessionalGender'];
    }
    if(json.containsKey('serviceFulfillmentStartTime')) {
      serviceFulfillmentStartTime = json['serviceFulfillmentStartTime'];
    }
    if(json.containsKey('serviceFulfillmentEndTime')) {
      serviceFulfillmentEndTime = json['serviceFulfillmentEndTime'];
    }
    if(json.containsKey('serviceFulfillmentType')) {
      serviceFulfillmentType = json['serviceFulfillmentType'];
    }
    if(json.containsKey('symptoms')) {
      symptoms = json['symptoms'];
    }
    if(json.containsKey('languagesSpokenByHealthcareProfessional')) {
      languagesSpokenByHealthcareProfessional =
      json['languagesSpokenByHealthcareProfessional'];
    }
    if(json.containsKey('healthcareProfessionalExperience')) {
      healthcareProfessionalExperience = json['healthcareProfessionalExperience'];
    }
    if(json.containsKey('isServiceFulfilled')) {
      isServiceFulfilled = json['isServiceFulfilled'];
    }
    if(json.containsKey('healthcareProfessionalDepartment')) {
      healthcareProfessionalDepartment = json['healthcareProfessionalDepartment'];
    }
    if(json.containsKey('message')) {
      message = json['message'];
    }
    if(json.containsKey('slotId')) {
      slotId = json['slotId'];
    }
    if(json.containsKey('transId')) {
      transId = json['transId'];
    }
    if(json.containsKey('primaryDoctor')) {
      primaryDoctor = json['primaryDoctor'];
    }
    if(json.containsKey('secondaryDoctor')) {
      secondaryDoctor = json['secondaryDoctor'];
    }
    if(json.containsKey('groupConsultStatus') && json['groupConsultStatus'] != null) {
      groupConsultStatus = json['groupConsultStatus'].toString().toLowerCase() == 'true';
    }
    if(json.containsKey('abhaId')) {
      abhaId = json['abhaId'];
    }
    if(json.containsKey('patientName')) {
      patientName = json['patientName'];
    }
    if(json.containsKey('patientGender')) {
      patientGender = json['patientGender'];
    }
    if(json.containsKey('patientConsumerUrl')) {
      patientConsumerUri = json['patientConsumerUrl'];
    }
    if(json.containsKey('primaryDoctorName')) {
      primaryDoctorName = json['primaryDoctorName'];
    }
    if(json.containsKey('primaryDoctorHprAddress')) {
      primaryDoctorHprAddress = json['primaryDoctorHprAddress'];
    }
    if(json.containsKey('primaryDoctorGender')) {
      primaryDoctorGender = json['primaryDoctorGender'];
    }
    if(json.containsKey('primaryDoctorProviderURI')) {
      primaryDoctorProviderUri = json['primaryDoctorProviderURI'];
    }
    if(json.containsKey('secondaryDoctorName')) {
      secondaryDoctorName = json['secondaryDoctorName'];
    }
    if(json.containsKey('secondaryDoctorHprAddress')) {
      secondaryDoctorHprAddress = json['secondaryDoctorHprAddress'];
    }
    if(json.containsKey('secondaryDoctorGender')) {
      secondaryDoctorGender = json['secondaryDoctorGender'];
    }
    if(json.containsKey('secondaryDoctorProviderURI')) {
      secondaryDoctorProviderUri = json['secondaryDoctorProviderURI'];
    }
    if(json.containsKey('payment')) {
      payment =
      json['payment'] != null ? Payment.fromJson(json['payment']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['categoryId'] = categoryId;
    data['appointmentId'] = appointmentId;
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
    data['transId'] = transId;
    data['primaryDoctor'] = primaryDoctor;
    data['secondaryDoctor'] = secondaryDoctor;
    if(groupConsultStatus == null) {
      data['groupConsultStatus'] = 'false';
    } else {
      data['groupConsultStatus'] = groupConsultStatus! ? 'true' : 'false';
    }
    data['abhaId'] = abhaId;
    data['patientName'] = patientName;
    data['patientGender'] = patientGender;
    data['patientConsumerUrl'] = patientConsumerUri;
    data['primaryDoctorName'] = primaryDoctorName;
    data['primaryDoctorHprAddress'] = primaryDoctorHprAddress;
    data['primaryDoctorGender'] = primaryDoctorGender;
    data['primaryDoctorProviderURI'] = primaryDoctorProviderUri;
    data['secondaryDoctorName'] = secondaryDoctorName;
    data['secondaryDoctorHprAddress'] = secondaryDoctorHprAddress;
    data['secondaryDoctorGender'] = secondaryDoctorGender;
    data['secondaryDoctorProviderURI'] = secondaryDoctorProviderUri;
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
    var s = data['method'] = method;
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
