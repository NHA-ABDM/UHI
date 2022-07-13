import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:hspa_app/constants/src/strings.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/services/services.dart';
import 'package:hspa_app/utils/src/utility.dart';

import '../../common/src/dialog_helper.dart';
import '../../constants/src/request_urls.dart';
import '../../model/response/src/access_token_response.dart';
import '../../model/response/src/hpr_id_profile_response.dart';
import '../../model/response/src/provider_response.dart' as provider_response;
import '../../model/response/src/validate_otp_response.dart';

class AuthenticationController extends GetxController with ExceptionHandler {
  ///ERROR STRING
  var errorString = '';

  Future<provider_response.ProviderListResponse?> getProviderDetails(
      {required String identifier}) async {
    provider_response.ProviderListResponse? providerListResponse =
        await BaseClient(url: "${RequestUrls.getProvider}?v=full&q=$identifier")
            .get()
            .then(
      (value) async {
        if (value == null) {
        } else {
          String? response = value;
          debugPrint('GET Provider Details response is $response');

          provider_response.ProviderListResponse? providerListResponse =
          provider_response.ProviderListResponse.fromJson(json.decode(response!));
          debugPrint('GET Provider Details response parsed successfully ${providerListResponse.results?.length}');
          await processAndSaveDoctorProfile(providerListResponse);

          return providerListResponse;
        }
      },
    ).catchError(
      (onError) {
        debugPrint('GET Provider Details error is ${onError.message}');

        errorString = "${onError.message}";

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return providerListResponse;
  }

  Future<void> processAndSaveDoctorProfile(provider_response.ProviderListResponse providerListResponse) async{
    if (providerListResponse.results!.isNotEmpty) {
      provider_response.Results results = providerListResponse.results![0];

      String uuid = results.uuid!;
      String displayName = results.person!.display!;
      String gender = results.person!.gender!;
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
      for (provider_response.Attributes attributes in results.attributes!) {
        debugPrint(
            'Attributes are ${attributes.attributeType!.display} -> ${attributes.value} --> ${attributes.uuid}');
        switch (attributes.attributeType!.uuid) {
          case ProviderAttributesLocal.profilePhotoAttribute:
            profilePhoto = attributes.value;
            break;
          case ProviderAttributesLocal.educationAttribute:
            education = attributes.value;
            break;
          case ProviderAttributesLocal.experienceAttribute:
            experience = attributes.value;
            break;
          case ProviderAttributesLocal.hprAddressAttribute:
            hprAddress = attributes.value;
            break;
          case ProviderAttributesLocal.hprIdAttribute:
            break;
          case ProviderAttributesLocal.languagesAttribute:
            languages = attributes.value;
            break;
          case ProviderAttributesLocal.specialityAttribute:
            speciality = attributes.value;
            break;
          case ProviderAttributesLocal.firstConsultation:
            firstConsultation = attributes.value;
            break;
          case ProviderAttributesLocal.followUp:
            followUp = attributes.value;
            break;
          case ProviderAttributesLocal.labReportConsultation:
            labReportConsultation = attributes.value;
            break;
          case ProviderAttributesLocal.psFirstConsultation:
            psFirstConsultation = attributes.value;
            break;
          case ProviderAttributesLocal.psFollowUp:
            psFollowUp = attributes.value;
            break;
          case ProviderAttributesLocal.psLabReportConsultation:
            psLabReportConsultation = attributes.value;
            break;
          case ProviderAttributesLocal.upiId:
            upiId = attributes.value;
            break;
          case ProviderAttributesLocal.receivePayment:
            receivePayment = attributes.value;
            break;
          case ProviderAttributesLocal.signature:
            signature = attributes.value;
            break;
          case ProviderAttributesLocal.isTeleconsultation:
            isTeleconsultation = attributes.value!.toLowerCase() == 'true';
            break;
          case ProviderAttributesLocal.isPhysicalConsultation:
            isPhysicalConsultation = attributes.value!.toLowerCase() == 'true';
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

  Future<AccessTokenResponse?> getSessionToken() async {
    Map<String, dynamic> requestBody = {
      "clientId": "hp_id",
      "clientSecret": "5bbba57e-39b1-4f36-a664-5bc552319474",
      "grantType": "client_credentials"
    };

    debugPrint('get access token request body is $requestBody');
    AccessTokenResponse? accessTokenResponse = await BaseClient(
      url: RequestUrls.getSessionToken,
      body: requestBody,
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if(response != null) {
            AccessTokenResponse? accessTokenResponse = AccessTokenResponse
                .fromJson(json.decode(response));
            debugPrint('Get access token response parsed successfully ${accessTokenResponse.accessToken}');
            return accessTokenResponse;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Get access token error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return accessTokenResponse;
  }

  Future<String?> sendMobileOtp({required String mobileNumber, required String accessToken}) async {
    Map<String, dynamic> requestBody = {
      "mobile": mobileNumber
    };

    debugPrint('Send mobile otp request body is $requestBody');
    String? transactionId = await BaseClient(
      url: RequestUrls.sendMobileOtp,
      body: requestBody,
      headers: {
        'Accept': 'application/json',
        'Content-type': 'application/json',
        'Content-Language': 'mobile',
        'authorization': 'Bearer $accessToken',
      }
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          if(value != null) {
            String? transactionId;

            Map<String, dynamic> responseData = json.decode(value);
            if(responseData.containsKey('txnId')){
              transactionId = responseData['txnId'];
            }

            debugPrint('Send mobile otp response parsed successfully $transactionId');
            return transactionId;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Send mobile otp error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return transactionId;
  }

  Future<ValidateOTPResponse?> verifyMobileOtp({required String transactionId, required String otp, required String accessToken}) async {

    Encrypted encryptedOtp = await Utility.encryptString(value: otp);

    Map<String, dynamic> requestBody = {
      "txnId": transactionId,
      "otp" : encryptedOtp.base64
    };

    debugPrint('verify mobile otp request body is $requestBody');
    ValidateOTPResponse? validateOTPResponse = await BaseClient(
      url: RequestUrls.verifyMobileOtp,
      body: requestBody,
        headers: {
          'Accept': 'application/json',
          'Content-type': 'application/json',
          'Content-Language': 'mobile',
          'authorization': 'Bearer $accessToken',
        }
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if(response != null) {
            ValidateOTPResponse? validateOTPResponse = ValidateOTPResponse
                .fromJson(json.decode(response));
            debugPrint('Get access token response parsed successfully ${validateOTPResponse.token}');
            return validateOTPResponse;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('verify mobile otp error $onError');
        errorString = onError.toString();
        if(onError is BadRequestException){
          if(onError.message!.contains('HPID/UserID/Year is Incorrect')){
            DialogHelper.showErrorDialog(description: AppStrings().errorNoHprLinkedToMobile);
          } else {
            handleError(onError, isShowDialog: true, isShowSnackbar: false);
          }
        } else {
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        }
      },
    );
    return validateOTPResponse;
  }

  Future<String?> getHprIdAuthToken({required String transactionId, required String hpId, required String accessToken}) async {

    Map<String, dynamic> requestBody = {
      "txnId": transactionId,
      "hpId" : hpId
    };

    debugPrint('Get hpId auth token request body is $requestBody');
    String? token = await BaseClient(
        url: RequestUrls.getHprIdAuthToken,
        body: requestBody,
        headers: {
          'Accept': 'application/json',
          'Content-type': 'application/json',
          'Content-Language': 'mobile',
          'authorization': 'Bearer $accessToken',
        }
    ).post()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          if(value != null) {
            String? token;

            Map<String, dynamic> responseData = json.decode(value);
            if(responseData.containsKey('token')){
              token = responseData['token'];
            }

            debugPrint('Get hpId auth token response parsed successfully $token');
            return token;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Get hpId auth token error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return token;
  }

  Future<HPRIDProfileResponse?> getHprIdDoctorProfile({required String authToken, required String accessToken}) async {
    HPRIDProfileResponse? hprIdProfileResponse = await BaseClient(
        url: RequestUrls.getHprIdDoctorProfile,
        headers: {
          'Accept': 'application/json',
          'Content-type': 'application/json',
          'Content-Language': 'mobile',
          'authorization': 'Bearer $accessToken',
          'X-Token': 'Bearer $authToken',
        }
    ).get()
        .then(
          (value) async {
        if (value == null) {
          return null;
        } else {
          String? response = value;
          if(response != null) {
            HPRIDProfileResponse? hprIdProfileResponse = HPRIDProfileResponse
                .fromJson(json.decode(response));
            debugPrint('Get hpId profile api response parsed successfully ${hprIdProfileResponse.hprId}');
            return hprIdProfileResponse;
          }
          return null;
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Get hpId profile error $onError');
        errorString = onError.toString();
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
    return hprIdProfileResponse;
  }
}
