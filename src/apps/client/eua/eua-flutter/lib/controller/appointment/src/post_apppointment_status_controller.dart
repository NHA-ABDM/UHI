import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/acknowledgement_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class PostAppointmentStatusController extends GetxController
    with ExceptionHandler {
  ///APPOINTMENT STATUS DETAILS
  AcknowledgementResponseModel? appointmentStatusAckDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> postAppointmentStatusDetails(
      {Object? appointmentStatusDetails}) async {
    if (appointmentStatusDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.postAppointmentStatus,
            body: appointmentStatusDetails)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          AcknowledgementResponseModel acknowledgementModel =
              AcknowledgementResponseModel.fromJson(value);
          setappointmentStatusDetails(
              acknowledgementModel: acknowledgementModel);
        }
      },
    ).catchError(
      (onError) {
        log("Post Appointment Status Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setappointmentStatusDetails(
      {required AcknowledgementResponseModel? acknowledgementModel}) {
    if (acknowledgementModel == null) {
      return;
    }

    appointmentStatusAckDetails = acknowledgementModel;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST appointmentStatus DETAILS
    // postAppointmentStatusDetails();
  }
}
