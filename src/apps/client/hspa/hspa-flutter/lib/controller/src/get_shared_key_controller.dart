import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/src/request_urls.dart';
import '../../services/src/exception_handler.dart';
import '../../services/src/service.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class GetSharedKeyController extends GetxController with ExceptionHandler {
  ///FCM TOKEN DETAILS
  var sharedKeyDetails;

  /*///STATE
  var state = DataState.loading.obs;*/

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getSharedKeyDetails(
      {String? doctorId, String? patientId}) async {
    /*if (patientId == null) {
      state.value = DataState.loading;
    }*/

    await BaseClient(url: "${RequestUrls.getPrivatePublicKey}/$patientId")
        .get()
        .then(
      (value) {

        debugPrint('Get private public key response is $value');

        if (value != null) {
          setSharedKeyDetails(responseData: value);
          debugPrint('set shared key is $sharedKeyDetails');
        }
      },
    ).catchError(
      (onError) {
        log("Post Shared Key Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    // state.value = DataState.complete;
  }

  setSharedKeyDetails({required var responseData}) {
    if (responseData == null) {
      return;
    }

    sharedKeyDetails = responseData;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST FCM TOKEN DETAILS
    // postFCM TOKENDetails();
  }
}
