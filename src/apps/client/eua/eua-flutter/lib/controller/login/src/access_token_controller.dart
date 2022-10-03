import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/request/src/access_token_request_model.dart';
import 'package:uhi_flutter_app/model/response/src/access_token_response_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';

import '../../../constants/src/request_urls.dart';

class AccessTokenController extends GetxController with ExceptionHandler {
  AccessTokenResponseModel? accessTokenResponseModel;

  var state = DataState.loading.obs;

  var errorString = '';

  Future<void> postAccessTokenAPI() async {
    AccessTokenRequestModel accessTokenRequestModel = AccessTokenRequestModel();
    accessTokenRequestModel.clientId = "TEST_PHR";
    accessTokenRequestModel.clientSecret =
        "4cada55c-fe4d-426f-bd0a-488167293838";
    accessTokenRequestModel.grantType = "client_credentials";
    if (accessTokenRequestModel == null) {
      state.value = DataState.loading;
    }

    await BaseClient(
            url: RequestUrls.getAccessTokenUrl, body: accessTokenRequestModel)
        .postAccessToken()
        .then(
      (value) {
        if (value == null) {
        } else {
          AccessTokenResponseModel accessTokenResponseModel =
              AccessTokenResponseModel.fromJson(value);
          setAccessTokenDetails(accessTokenResponse: accessTokenResponseModel);
        }
      },
    ).catchError(
      (onError) {
        log("Post Access token Details $onError ${onError.message}");

        errorString = "${onError.message}";

        //handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
  }

  setAccessTokenDetails(
      {required AccessTokenResponseModel? accessTokenResponse}) {
    if (accessTokenResponse == null) {
      return;
    }
    accessTokenResponseModel = accessTokenResponse;
    String? accessToken = accessTokenResponseModel?.accessToken;
    if (accessToken != null) {
      SharedPreferencesHelper.setAccessToken(accessToken);
    }
  }

  @override
  refresh() async {
    errorString = '';
  }
}
