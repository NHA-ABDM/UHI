import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/services/services.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class LogoutController extends GetxController with ExceptionHandler {
  ///logout DETAILS
  var logoutResponse;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postLogoutDetails({Object? logoutDetails}) async {
    if (logoutDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postLogoutDetails, body: logoutDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          setLogoutDetails(logoutResponseData: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Logout Details $onError ${onError.message}");

        errorString = "${onError.message}";

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setLogoutDetails({required var logoutResponseData}) {
    if (logoutResponseData == null) {
      return;
    }

    logoutResponse = logoutResponseData;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST logout DETAILS
    // postlogoutDetails();
  }
}
