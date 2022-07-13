import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/services/services.dart';

import '../../constants/src/provider_attributes.dart';
import '../../constants/src/request_urls.dart';
import '../../model/response/src/register_provider_response.dart';
import '../../model/src/doctor_profile.dart';

class RegisterProviderController extends GetxController with ExceptionHandler {
  ///ERROR STRING
  var errorString = '';
  
  Future<RegisterProviderResponse?> registerProvider(
      {required Map<String, dynamic> requestBody}) async {

    debugPrint('Register provider request body is $requestBody');
    RegisterProviderResponse? registerProviderResponse = await BaseClient(
      url: RequestUrls.getProvider,
      body: requestBody,
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if(response != null) {
            RegisterProviderResponse? registerProviderResponse = RegisterProviderResponse
                .fromJson(json.decode(response));
            debugPrint('Register provider response parsed successfully ${registerProviderResponse.uuid}');
            await processAndSaveDoctorProfile(registerProviderResponse, requestBody);
            return registerProviderResponse;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Register provider error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return registerProviderResponse;
  }

  Future<void> processAndSaveDoctorProfile(RegisterProviderResponse registerProviderResponse, Map<String, dynamic> requestBody) async{

      String uuid = registerProviderResponse.uuid!;
      String displayName = registerProviderResponse.person!.display!;
      String gender = requestBody['person']['gender'];
      String? profilePhoto;
      String? speciality;
      String? medicineType = 'Allopathy';
      String? experience;
      String? education;
      String? languages;
      String? hprAddress;
      String? firstConsultation;
      String? followUp;
      String? labReportConsultation;
      String? psFirstConsultation;
      String? psFollowUp;
      String? psLabReportConsultation;
      String? upiId;
      String? receivePayment;
      String? signature;
      bool? isTeleconsultation;
      bool? isPhysicalConsultation;

      for(Map<String, dynamic> attributeMap in requestBody['attributes']) {
        switch(attributeMap['attributeType']){
          case ProviderAttributesLocal.profilePhotoAttribute:
            profilePhoto = attributeMap['value'];
            break;
          case ProviderAttributesLocal.educationAttribute:
            education = attributeMap['value'];
            break;
          case ProviderAttributesLocal.experienceAttribute:
            experience = attributeMap['value'];
            break;
          case ProviderAttributesLocal.hprAddressAttribute:
            hprAddress = attributeMap['value'];
            break;
          case ProviderAttributesLocal.hprIdAttribute:
            break;
          case ProviderAttributesLocal.languagesAttribute:
            languages = attributeMap['value'];
            break;
          case ProviderAttributesLocal.specialityAttribute:
            speciality = attributeMap['value'];
            break;
          case ProviderAttributesLocal.firstConsultation:
            firstConsultation = attributeMap['value'];
            break;
          case ProviderAttributesLocal.followUp:
            followUp = attributeMap['value'];
            break;
          case ProviderAttributesLocal.labReportConsultation:
            labReportConsultation = attributeMap['value'];
            break;
          case ProviderAttributesLocal.psFirstConsultation:
            psFirstConsultation = attributeMap['value'];
            break;
          case ProviderAttributesLocal.psFollowUp:
            psFollowUp = attributeMap['value'];
            break;
          case ProviderAttributesLocal.psLabReportConsultation:
            psLabReportConsultation = attributeMap['value'];
            break;
          case ProviderAttributesLocal.upiId:
            upiId = attributeMap['value'];
            break;
          case ProviderAttributesLocal.receivePayment:
            receivePayment = attributeMap['value'];
            break;
          case ProviderAttributesLocal.signature:
            signature = attributeMap['value'];
            break;
          case ProviderAttributesLocal.isTeleconsultation:
            isTeleconsultation = attributeMap['value'].toLowerCase() == 'true';
            break;
          case ProviderAttributesLocal.isPhysicalConsultation:
            isPhysicalConsultation = attributeMap['value'].toLowerCase() == 'true';
            break;
        }
      }

      DoctorProfile doctorProfile = DoctorProfile(
        uuid: uuid,
        displayName: displayName,
        gender: gender,
        profilePhoto: profilePhoto,
        speciality: speciality,
        medicineType: medicineType,
        experience:  experience,
        education:  education,
        languages: languages,
        hprAddress: hprAddress,
        firstConsultation: firstConsultation,
        followUp: followUp,
        labReportConsultation: labReportConsultation,
        psFirstConsultation: psFirstConsultation,
        psFollowUp: psFollowUp,
        psLabReportConsultation: psLabReportConsultation,
        upiId: upiId,
        receivePayment: receivePayment,
        signature: signature,
        isTeleconsultation: isTeleconsultation,
        isPhysicalConsultation: isPhysicalConsultation,
      );

      await doctorProfile.saveDoctorProfile();

  }

}