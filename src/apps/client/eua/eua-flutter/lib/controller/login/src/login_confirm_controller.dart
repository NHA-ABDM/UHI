import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/login_confirm_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';

import '../../../constants/src/request_urls.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class LoginConfirmController extends GetxController with ExceptionHandler {
  ///LOGIN DETAILS
  LoginConfirmResponseModel? loginConfirmResponseModel;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postConfirm({LoginConfirmRequestModel? loginDetails}) async {
    if (loginDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postLoginConfirm, body: loginDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          LoginConfirmResponseModel loginConfirmResponseModel =
              LoginConfirmResponseModel.fromJson(value);
          setLoginDetails(loginConfirmResponse: loginConfirmResponseModel);
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

  setLoginDetails({required LoginConfirmResponseModel? loginConfirmResponse}) {
    if (loginConfirmResponse == null) {
      return;
    }

    loginConfirmResponseModel = loginConfirmResponse;
    String? accessToken = loginConfirmResponseModel?.token;
    if (accessToken != null) {
      SharedPreferencesHelper.setAuthHeaderToken(accessToken);
    }
  }

  @override
  refresh() async {
    errorString = '';

    ///POST login DETAILS
    // postLoginDetails();
  }
}
