import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/logout_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class LogoutController extends GetxController with ExceptionHandler {
  ///LOGIN DETAILS
  LogoutResponseModel? logoutResponseModel;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postConfirm({LogoutRequestModel? loginDetails}) async {
    if (loginDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postLoginInitAuth, body: loginDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          LogoutResponseModel logoutResponseModel =
              LogoutResponseModel.fromJson(value);
          setLoginDetails(logoutResponse: logoutResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("Post Login Details $onError ${onError.message}");

        errorString = "${onError.message}";

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setLoginDetails({required LogoutResponseModel? logoutResponse}) {
    if (logoutResponse == null) {
      return;
    }

    logoutResponseModel = logoutResponse;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST login DETAILS
    // postLoginDetails();
  }
}
