import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

class AbhaNumberController extends GetxController with ExceptionHandler {
  ///ABHA NUMBER DETAILS
  var abhaNumberAckDetails;
  var abhaAuthAckDetails;
  var abhaValidateAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postAbhaNumberDetails({Object? abhaNumberDetails}) async {
    if (abhaNumberDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postAbhaAuthMode, body: abhaNumberDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          setAbhaNumberResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Abha Number Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setAbhaNumberResponse({required var response}) {
    if (response == null) {
      return;
    }

    abhaNumberAckDetails = response;
  }

  Future<void> postAbhaAuthDetails({Object? abhaAuthDetails}) async {
    if (abhaAuthDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postAbhaGenerateOtpWithAuthMode,
            body: abhaAuthDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          setAbhaAuthResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Abha AUTH Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setAbhaAuthResponse({required var response}) {
    if (response == null) {
      return;
    }

    abhaAuthAckDetails = response;
  }

  Future<void> postAbhaValidateDetails({Object? abhaValidateDetails}) async {
    if (abhaValidateDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postAbhaValidateOtpWithAuthMode,
            body: abhaValidateDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          setAbhaValidateResponse(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Abha AUTH Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setAbhaValidateResponse({required var response}) {
    if (response == null) {
      return;
    }

    abhaValidateAckDetails = response;
  }

  @override
  refresh() async {
    errorString = '';
    abhaNumberAckDetails = null;
    abhaAuthAckDetails = null;
    abhaValidateAckDetails = null;

    ///POST FCM TOKEN DETAILS
    // postFCM TOKENDetails();
  }
}
