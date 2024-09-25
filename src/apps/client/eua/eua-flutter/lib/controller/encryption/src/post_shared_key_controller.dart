import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/services/services.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class PostSharedKeyController extends GetxController with ExceptionHandler {
  ///SHARED KEY DETAILS
  var sharedKeyAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postSharedKeyDetails({Object? sharedKeyDetails}) async {
    if (sharedKeyDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postSharedKey, body: sharedKeyDetails)
        .postWithGatewayHeader()
        .then(
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

    sharedKeyAckDetails = responseData;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST FCM TOKEN DETAILS
    // postFCM TOKENDetails();
  }
}
