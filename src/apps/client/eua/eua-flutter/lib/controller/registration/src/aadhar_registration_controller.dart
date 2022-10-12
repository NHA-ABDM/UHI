import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

class AadharRegistrationController extends GetxController
    with ExceptionHandler {
  ///AADHAR REGISTRATIONS VARIABLES
  AccessTokenResponseModel? sessionTokenDetails;
  var authCertDetails;
  var aadhaarOtpDetails;
  var aadhaarOtpVerifyDetails;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  ///SESSION TOKEN REQUEST
  Future<void> postSessionToken() async {
    AccessTokenRequestModel accessTokenRequestModel = AccessTokenRequestModel();
    accessTokenRequestModel.clientId = "healthid-api";
    accessTokenRequestModel.clientSecret =
        "9042c774-f57b-46ba-bb11-796a4345ada1";
    accessTokenRequestModel.grantType = "client_credentials";

    await BaseClient(
      url: RequestUrls.getAccessTokenUrl,
      body: accessTokenRequestModel,
    ).postAccessToken().then(
      (value) {
        if (value == null) {
        } else {
          AccessTokenResponseModel accessTokenResponseModel =
              AccessTokenResponseModel.fromJson(value);
          setSessionTokenResponse(response: accessTokenResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("Get Session Token Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

  ///SESSION TOKEN RESPONSE
  setSessionTokenResponse({required var response}) {
    if (response == null) {
      return;
    }

    sessionTokenDetails = response;
  }

  ///AUTH CERT REQUEST
  Future<void> getAuthCert() async {
    await BaseClient(url: RequestUrls.getAuthCert).get().then(
      (value) {
        if (value == null) {
        } else {
          setAuthCertResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Get Auth Cert Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

  ///AUTH CERT RESPONSE
  setAuthCertResponse({required var response}) {
    if (response == null) {
      return;
    }

    authCertDetails = response;
  }

  ///GENERATE OTP REQUEST
  Future<void> postGenerateAadhaarOtpDetails(
      {Object? aadhaarDetails, required String authToken}) async {
    await BaseClient(
            url: RequestUrls.postGenerateAadhaarOtp, body: aadhaarDetails)
        .postWithRegistrationHeaders()
        .then(
      (value) {
        if (value == null) {
        } else {
          setAadhaarOtpResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Generate AADHAR Otp Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

  ///GENERATE OTP RESPONSE
  setAadhaarOtpResponse({required var response}) {
    if (response == null) {
      return;
    }

    aadhaarOtpDetails = response;
  }

  ///VALIDATE OTP REQUEST
  Future<void> postValidateAadhaarOtpDetails({Object? aadhaarOtpObj}) async {
    await BaseClient(
            url: RequestUrls.postValidateAadhaarOtp, body: aadhaarOtpObj)
        .postWithRegistrationHeaders()
        .then(
      (value) {
        if (value == null) {
        } else {
          setAadhaarOtpValidateResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Validate AADHAR Otp Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

  ///VALIDATE OTP RESPONSE
  setAadhaarOtpValidateResponse({required var response}) {
    if (response == null) {
      return;
    }

    aadhaarOtpVerifyDetails = response;
  }

  @override
  refresh() async {
    errorString = '';
    sessionTokenDetails = null;
    authCertDetails = null;
    aadhaarOtpDetails = null;
    aadhaarOtpVerifyDetails = null;
  }
}
