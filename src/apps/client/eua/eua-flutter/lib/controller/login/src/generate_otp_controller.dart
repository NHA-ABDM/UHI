import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/services/services.dart';

class GenerateOtpController extends GetxController with ExceptionHandler {
  ///GENERATE OTP DETAILS
  var generateOtpAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postGenerateOtpDetails({Object? generateOtpDetails}) async {
    if (generateOtpDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postGenerateOtpUrl, body: generateOtpDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          setGenerateOtpResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Generate Otp Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setGenerateOtpResponse({required var response}) {
    if (response == null) {
      return;
    }

    generateOtpAckDetails = response;
  }

  @override
  refresh() async {
    errorString = '';
    generateOtpAckDetails = null;

    ///POST FCM TOKEN DETAILS
    // postFCM TOKENDetails();
  }
}
