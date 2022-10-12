import 'dart:developer';

import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/services/services.dart';

import '../../../model/response/src/abha_address_suggestions_response_model.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class AbhaAddressSuggestionsController extends GetxController
    with ExceptionHandler {
  ///SUGGESTION API RESPONSE
  AbhaAddressSuggestionsResponseModel? abhaAddressSuggestionsResponse;
  CreatePhrAddressResponseModel? createPhrAddressResponseModel;
  var createPhrAddressResponse;
  AlreadyExistsPhrAddressResponseModel? alreadyExistingPhrResponse;

  ///ERROR STRING
  var errorString = '';

  Future<void> postSuggestApi({Object? suggestionRequest}) async {
    await BaseClient(
            url: RequestUrls.postSuggestionUrl, body: suggestionRequest)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          AbhaAddressSuggestionsResponseModel suggestionsApiResponse =
              AbhaAddressSuggestionsResponseModel.fromJson(value);
          setSuggestionsDetails(suggestionsApiResponse: suggestionsApiResponse);
        }
      },
    ).catchError(
      (onError) {
        abhaAddressSuggestionsResponse = null;
        log("Post Errors Details ${onError.message}");
        errorString = "${onError.message}";
        if (errorString != "value is marked non-null but is null") {
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        }
      },
    );
  }

  Future<void> postCreatePhrAddressApi(
      {required CreatePhrAddressRequestModel?
          createPhrAddressRequestModel}) async {
    await BaseClient(
            url: RequestUrls.postCreatePhrAddressUrl,
            body: createPhrAddressRequestModel)
        .post()
        .then(
      (value) {
        if (value == null) {
        } else {
          CreatePhrAddressResponseModel createPhrAddressResponseModel =
              CreatePhrAddressResponseModel.fromJson(value);
          setCreatePhrAddressResponseDetails(
              createPhrAddressResponseModel: createPhrAddressResponseModel);
          setCreatePhrAddressResponse(response: createPhrAddressResponseModel);
        }
      },
    ).catchError(
      (onError) {
        abhaAddressSuggestionsResponse = null;
        log("Post Errors Details ${onError.message}");
        errorString = "${onError.message}";
        if (errorString != "value is marked non-null but is null") {
          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        }
      },
    );
  }

  Future<void> getIfAlreadyExistsPhrAddress(String phrAddress) async {
    await BaseClient(
            url: "${RequestUrls.checkIfAlreadyExistingUrl}?phrAddress=" +
                phrAddress)
        .get()
        .then(
      (value) {
        if (value == null) {
        } else {
          AlreadyExistsPhrAddressResponseModel alreadyExisingPhrResponse =
              AlreadyExistsPhrAddressResponseModel.fromJson(value);

          setAlreadyExistingPhrAddressResponse(
              alreadyExistingPhrResponse: alreadyExisingPhrResponse);
        }
      },
    ).catchError(
      (onError) {
        // log("Post Chat Message Details $onError ${onError.message}");
        // errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

  setSuggestionsDetails(
      {required AbhaAddressSuggestionsResponseModel? suggestionsApiResponse}) {
    if (suggestionsApiResponse == null) {
      return;
    }

    abhaAddressSuggestionsResponse = suggestionsApiResponse;
  }

  setCreatePhrAddressResponseDetails(
      {required CreatePhrAddressResponseModel? createPhrAddressResponseModel}) {
    if (createPhrAddressResponseModel == null) {
      return;
    }

    createPhrAddressResponseModel = createPhrAddressResponseModel;
  }

  setCreatePhrAddressResponse({required var response}) {
    if (response == null) {
      return;
    }

    createPhrAddressResponse = response;
  }

  setAlreadyExistingPhrAddressResponse(
      {required AlreadyExistsPhrAddressResponseModel?
          alreadyExistingPhrResponse}) {
    if (alreadyExistingPhrResponse == null) {
      return;
    }

    alreadyExistingPhrResponse = alreadyExistingPhrResponse;
  }

  @override
  refresh() async {
    errorString = '';
    abhaAddressSuggestionsResponse = null;
    createPhrAddressResponseModel = null;
    alreadyExistingPhrResponse = null;
  }
}
