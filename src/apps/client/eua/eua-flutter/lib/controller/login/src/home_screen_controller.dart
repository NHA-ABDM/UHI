import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/get_upcoming_appointments_response.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/services/services.dart';

import '../../../constants/src/request_urls.dart';

class HomeScreenController extends GetxController with ExceptionHandler {
  GetUserDetailsResponse? getUserDetailsResponseModel;
  List<UpcomingAppointmentResponseModal?> upcomingAppointmentResponseModal = [];

  var state = DataState.loading.obs;

  var errorString = '';

  Future<void> getUserDetailsAPI() async {
    await BaseClient(url: RequestUrls.getUserDetailsAPI).getWithHeaders().then(
      (value) {
        if (value == null) {
        } else {
          GetUserDetailsResponse getUserDetailsResponseModel =
              GetUserDetailsResponse.fromJson(value);
          setUserDetails(getUserDetailsResponse: getUserDetailsResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("Get User Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  Future<void> saveUserDataToEUA(
      GetUserDetailsResponse? getUserDetailsResponseModel) async {
    await BaseClient(
            url: RequestUrls.saveUserDataToEUA,
            body: getUserDetailsResponseModel)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {}
      },
    ).catchError(
      (onError) {
        log("save User Details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  Future<void> getUserDataFromEUA(String abhaAddress) async {
    await BaseClient(
      url: RequestUrls.getUserDataFromEUA + "/$abhaAddress",
    ).get().then(
      (value) {
        if (value == null) {
        } else {
          GetUserDetailsResponse getUserDetailsResponseModel =
              GetUserDetailsResponse.fromJson(value);
          setUserDetails(getUserDetailsResponse: getUserDetailsResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("getUserDataFromEUA $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setUserDetails({required GetUserDetailsResponse? getUserDetailsResponse}) {
    if (getUserDetailsResponse == null) {
      return;
    }
    getUserDetailsResponseModel = getUserDetailsResponse;
  }

  @override
  refresh() async {
    errorString = '';
    upcomingAppointmentResponseModal.clear();
  }

  Future<void> getUpcomingAppointment(String abhaId) async {
    await BaseClient(url: RequestUrls.getOrderDetails + abhaId).get().then(
      (value) {
        if (value == null) {
        } else {
          List<UpcomingAppointmentResponseModal>
              upcomingAppointmentResponseModal = [];
          List tempList = value;
          tempList.forEach((element) {
            upcomingAppointmentResponseModal
                .add(UpcomingAppointmentResponseModal.fromJson(element));
          });
          setUpcomingAppointmentDetails(
              upcomingAppointmentResponse: upcomingAppointmentResponseModal);
        }
      },
    ).catchError(
      (onError) {
        log("Get order details $onError ${onError.message}");
        errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setUpcomingAppointmentDetails(
      {required List<UpcomingAppointmentResponseModal?>
          upcomingAppointmentResponse}) {
    if (upcomingAppointmentResponse == null) {
      return;
    }
    upcomingAppointmentResponseModal = upcomingAppointmentResponse;
  }
}
