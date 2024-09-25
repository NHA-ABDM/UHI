import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
enum DataState { loading, complete }

class LoginInitController extends GetxController with ExceptionHandler {
  ///LOGIN DETAILS
  LoginInitResponseModel? loginInitResponseModel;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  Future<void> postInitAuth({LoginInitRequestModel? loginDetails}) async {
    if (loginDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postLoginInitAuth, body: loginDetails)
        .post()
        .then(
      (value) {
        log("Post Login Details ${loginDetails?.value} ");
        if (value == null) {
        } else {
          LoginInitResponseModel loginInitResponseModel =
              LoginInitResponseModel.fromJson(value);
          setLoginDetails(loginInitResponse: loginInitResponseModel);
        }
      },
    ).catchError(
      (onError) {
        loginInitResponseModel = null;
        log("Post Errors Details ${onError.message}");
        errorString = "${onError.message}";
        if (errorString != "value is marked non-null but is null") {
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        }
      },
    );

    state.value = DataState.complete;
  }

  setLoginDetails({required LoginInitResponseModel? loginInitResponse}) {
    if (loginInitResponse == null) {
      return;
    }

    loginInitResponseModel = loginInitResponse;
  }

  @override
  refresh() async {
    errorString = '';
    loginInitResponseModel = null;
  }
}
