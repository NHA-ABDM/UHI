import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

class GetDiscoveryDetailsController extends GetxController
    with ExceptionHandler {
  ///DISCOVERY DETAILS
  DiscoveryResponseModel? discoveryDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getDiscoveryDetails() async {
    if (discoveryDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.getDetails).get().then(
      (value) {
        if (value == null) {
        } else {
          // List tmpList = value;
          // List<DiscoveryResponseModel>? listOfResponseModel =
          //     List<DiscoveryResponseModel>.empty(growable: true);

          // for (var index = 0; index < tmpList.length; index++) {
          //   listOfResponseModel
          //       .add(DiscoveryResponseModel.fromJson(tmpList[index]));
          // }
          DiscoveryResponseModel discoveryResponseModel =
              DiscoveryResponseModel.fromJson(value);

          setDiscoveryDetails(discoveryDetailsModel: discoveryResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("GET Search Details $onError ${onError.message}");

        errorString = "${onError.message}";

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setDiscoveryDetails(
      {required DiscoveryResponseModel? discoveryDetailsModel}) {
    if (discoveryDetailsModel == null) {
      return;
    }

    discoveryDetails = discoveryDetailsModel;
  }

  @override
  refresh() async {
    discoveryDetails = null;
    errorString = '';

    // ///GET DISCOVERY DETAILS
    // getDiscoveryDetails();
  }
}
