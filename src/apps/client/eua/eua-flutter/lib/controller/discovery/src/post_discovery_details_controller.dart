import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
enum DataState { loading, complete }

class PostDiscoveryDetailsController extends GetxController
    with ExceptionHandler {
  ///DISCOVERY DETAILS
  AcknowledgementResponseModel? discoveryAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postDiscoveryDetails(
      {Object? discoveryDetails, String? discoveryType}) async {
    log("Discovery Url ${RequestUrls.postDiscoveryDetails}");
    if (discoveryDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postDiscoveryDetails, body: discoveryDetails)
        .postWithGatewayHeader()
        .then(
      (value) {
        if (value == null) {
        } else {
          AcknowledgementResponseModel acknowledgementModel =
              AcknowledgementResponseModel.fromJson(value);
          setDiscoveryDetails(acknowledgementModel: acknowledgementModel);
        }
      },
    ).catchError(
      (onError) {
        log("Post Discovery Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setDiscoveryDetails(
      {required AcknowledgementResponseModel? acknowledgementModel}) {
    if (acknowledgementModel == null) {
      return;
    }

    discoveryAckDetails = acknowledgementModel;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST DISCOVERY DETAILS
    // postDiscoveryDetails();
  }
}
