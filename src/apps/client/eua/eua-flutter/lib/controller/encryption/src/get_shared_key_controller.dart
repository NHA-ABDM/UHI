import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

import '../../../constants/src/request_urls.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class GetSharedKeyController extends GetxController with ExceptionHandler {
  ///FCM TOKEN DETAILS
  var sharedKeyDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getSharedKeyDetails(
      {String? doctorId, String? patientId}) async {
    if (patientId == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: "${RequestUrls.getSharedKey}$doctorId").get().then(
      (value) {
        if (value == null) {
        } else {
          // AcknowledgementResponseModel acknowledgementModel =
          //     AcknowledgementResponseModel.fromJson(value);
          setSharedKeyDetails(responseData: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Shared Key Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
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
