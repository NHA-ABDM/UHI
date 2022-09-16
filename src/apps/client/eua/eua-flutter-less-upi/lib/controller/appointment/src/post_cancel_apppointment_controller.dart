import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class PostCancelAppointmentController extends GetxController
    with ExceptionHandler {
  ///CANCEL APPOINTMENT DETAILS
  AcknowledgementResponseModel? appointmentAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postAppointmentDetails({Object? appointmentDetails}) async {
    if (appointmentDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postCancelAppointment, body: appointmentDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          AcknowledgementResponseModel acknowledgementModel =
              AcknowledgementResponseModel.fromJson(value);
          setappointmentDetails(acknowledgementModel: acknowledgementModel);
        }
      },
    ).catchError(
      (onError) {
        log("Post Appointment  Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setappointmentDetails(
      {required AcknowledgementResponseModel? acknowledgementModel}) {
    if (acknowledgementModel == null) {
      return;
    }

    appointmentAckDetails = acknowledgementModel;
  }

  @override
  refresh() async {
    errorString = '';
    appointmentAckDetails = null;

    ///POST appointment DETAILS
    // postAppointmentDetails();
  }
}
