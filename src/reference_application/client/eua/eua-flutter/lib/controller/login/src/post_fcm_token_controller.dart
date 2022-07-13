import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class PostFCMTokenController extends GetxController with ExceptionHandler {
  ///FCM TOKEN DETAILS
  var fcmTokenAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postFCMTokenDetails({Object? fcmTokenDetails}) async {
    if (fcmTokenDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postFCMToken, body: fcmTokenDetails)
        .postWithGatewayHeader()
        .then(
      (value) {
        if (value == null) {
        } else {
          // AcknowledgementResponseModel acknowledgementModel =
          //     AcknowledgementResponseModel.fromJson(value);
          setFcmTokenDetails(acknowledgementModel: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post FCM TOKEN Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setFcmTokenDetails({required var acknowledgementModel}) {
    if (acknowledgementModel == null) {
      return;
    }

    fcmTokenAckDetails = acknowledgementModel;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST FCM TOKEN DETAILS
    // postFCM TOKENDetails();
  }
}
