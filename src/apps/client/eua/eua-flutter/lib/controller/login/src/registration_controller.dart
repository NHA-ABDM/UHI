import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

class RegistrationController extends GetxController with ExceptionHandler {
  ///REGISTRATION DETAILS
  var registrationDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postRegistrationDetails({Object? registrationDetails}) async {
    if (registrationDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postRegistrationFormUrl, body: registrationDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          // AcknowledgementResponseModel acknowledgementModel =
          //     AcknowledgementResponseModel.fromJson(value);
          setRegistrationDetails(response: value);
        }
      },
    ).catchError(
      (onError) {
        log("Post Registration Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setRegistrationDetails({required var response}) {
    if (response == null) {
      return;
    }

    registrationDetails = response;
  }

  @override
  refresh() async {
    errorString = '';
    registrationDetails = null;
  }
}
