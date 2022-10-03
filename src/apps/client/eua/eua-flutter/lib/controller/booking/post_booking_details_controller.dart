import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/model/request/src/booking_on_confirm_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/model/response/src/booking_confirm_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';

import '../../constants/src/request_urls.dart';

///TO CHANGE STATE OF UI
enum DataState { loading, complete }

class PostBookingDetailsController extends GetxController
    with ExceptionHandler {
  ///DISCOVERY DETAILS
  AcknowledgementResponseModel? bookingAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postConfirmBookingDetails({
    BookOnConfirmResponseModel? bookOnConfirmResponseModel,
  }) async {
    if (bookOnConfirmResponseModel == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postConfirmBookingDetails,
            body: bookOnConfirmResponseModel)
        .post()
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

    bookingAckDetails = acknowledgementModel;
  }

  @override
  refresh() async {
    errorString = '';
  }
}
