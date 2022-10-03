import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

import '../../../constants/src/request_urls.dart';

///TO CHANGE STATE OF UI
enum DataState { loading, complete }

class PostProfessionalDetailsController extends GetxController
    with ExceptionHandler {
  ///PROFESSIONAL DETAILS
  AcknowledgementResponseModel? professionalAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postProfessionalDetails(
      {Object? professionalDetails, String? professionalType}) async {
    if (professionalDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postDiscoveryDetails, body: professionalDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          AcknowledgementResponseModel acknowledgementModel =
              AcknowledgementResponseModel.fromJson(value);
          setProfessionalDetails(acknowledgementModel: acknowledgementModel);
        }
      },
    ).catchError(
      (onError) {
        log("Post Professional Details $onError ${onError.message}");

        errorString = "${onError.message}";

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setProfessionalDetails(
      {required AcknowledgementResponseModel? acknowledgementModel}) {
    if (acknowledgementModel == null) {
      return;
    }

    professionalAckDetails = acknowledgementModel;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST Professional DETAILS
    // postProfessionalDetails();
  }
}
