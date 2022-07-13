import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/district_list_response_model%20copy.dart';
import 'package:uhi_flutter_app/model/response/src/state_list_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';

class RegisterWithAllInfoController extends GetxController
    with ExceptionHandler {
  List<StateListResponseModel?> stateListResponseModel = [];
  List<DistrictListResponseModel?> districtListResponseModel = [];

  var state = DataState.loading.obs;

  var errorString = '';

  Future<void> getStateList() async {
    await BaseClient(url: RequestUrls.getStateListUrl).get().then(
      (value) {
        if (value == null) {
        } else {
          List<StateListResponseModel> stateListResponseModel = [];
          List tempList = value;
          tempList.forEach((element) {
            stateListResponseModel
                .add(StateListResponseModel.fromJson(element));
          });
          setStateListDetails(stateListResponse: stateListResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("Get state list Details $onError ${onError.message}");

        errorString = "${onError.message}";

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  Future<void> getDistrictList(stateID) async {
    String districtUrl =
        RequestUrls.getDistrictListUrl + stateID + "/districts";
    await BaseClient(url: districtUrl).get().then(
      (value) {
        if (value == null) {
        } else {
          List<DistrictListResponseModel> districtListResponseModel = [];
          List tempList = value;
          tempList.forEach((element) {
            districtListResponseModel
                .add(DistrictListResponseModel.fromJson(element));
          });
          setDistrictListDetails(
              districtListResponse: districtListResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("Get district list Details $onError ${onError.message}");

        errorString = "${onError.message}";

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setStateListDetails(
      {required List<StateListResponseModel?> stateListResponse}) {
    if (stateListResponse.isEmpty) {
      return;
    }
    stateListResponseModel = stateListResponse;
  }

  setDistrictListDetails(
      {required List<DistrictListResponseModel?> districtListResponse}) {
    if (districtListResponse.isEmpty) {
      return;
    }
    districtListResponseModel = districtListResponse;
  }

  @override
  refresh() async {
    errorString = '';
  }
}
