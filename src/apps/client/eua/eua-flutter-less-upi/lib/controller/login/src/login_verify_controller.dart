import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/login_verify_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class LoginVerifyController extends GetxController with ExceptionHandler {
  ///LOGIN DETAILS
  LoginVerifyResponseModel? loginVerifyResponseModel;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postVerify({LoginVerifyRequestModel? loginDetails}) async {
    if (loginDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postLoginVerify, body: loginDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          LoginVerifyResponseModel loginVerifyResponseModel =
              LoginVerifyResponseModel.fromJson(value);
          setLoginDetails(loginVerifyResponse: loginVerifyResponseModel);
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

  setLoginDetails({required LoginVerifyResponseModel? loginVerifyResponse}) {
    if (loginVerifyResponse == null) {
      return;
    }

    loginVerifyResponseModel = loginVerifyResponse;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST login DETAILS
    // postLoginDetails();
  }
}
