import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/response/src/discovery_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

class GetLoginDetailsController extends GetxController with ExceptionHandler {
  ///LOGIN DETAILS
  List<DiscoveryResponseModel>? loginDetails;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getLoginDetails({String? messageId, String? getUrlType}) async {
    if (loginDetails == null) {
      state.value = DataState.loading;
    }

    await BaseClient(url: "${RequestUrls.getDetails}/$messageId").get().then(
      (value) {
        if (value == null) {
        } else {
          List tmpList = value;
          List<DiscoveryResponseModel>? listOfResponseModel =
              List<DiscoveryResponseModel>.empty(growable: true);

          for (var index = 0; index < tmpList.length; index++) {
            listOfResponseModel
                .add(DiscoveryResponseModel.fromJson(tmpList[index]));
          }

          setLoginDetails(loginDetailsModel: listOfResponseModel);
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

  setLoginDetails({required List<DiscoveryResponseModel>? loginDetailsModel}) {
    if (loginDetailsModel == null) {
      return;
    }

    loginDetails = loginDetailsModel;
  }

  @override
  refresh() async {
    loginDetails = null;
    errorString = '';
  }
}
