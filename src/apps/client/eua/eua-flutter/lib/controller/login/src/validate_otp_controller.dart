import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

class ValidateOtpController extends GetxController with ExceptionHandler {
  ///VALIDATE OTP DETAILS
  var validateOtpAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postValidateOtpDetails({Object? validateOtpDetails}) async {
    if (validateOtpDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postValidateOtpUrl, body: validateOtpDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          setValidateOtpResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post validate Otp Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setValidateOtpResponse({required var response}) {
    if (response == null) {
      return;
    }

    validateOtpAckDetails = response;
  }

  @override
  refresh() async {
    errorString = '';
    validateOtpAckDetails = null;

    ///POST FCM TOKEN DETAILS
    // postFCM TOKENDetails();
  }
}
