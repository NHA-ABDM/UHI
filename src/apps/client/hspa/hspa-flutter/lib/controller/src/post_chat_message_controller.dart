
import 'package:get/get.dart';

import '../../constants/src/request_urls.dart';
import '../../model/response/src/acknowledgement_response_model.dart';
import '../../services/src/exception_handler.dart';
import '../../services/src/service.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class PostChatMessageController extends GetxController with ExceptionHandler {
  ///CHAT MESSAGE DETAILS
  AcknowledgementResponseModel? chatMessageAckDetails;

  ///STATE
  //var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';


  Future<void> postChatMessageDetails(
      {Object? chatMessageDetails, String? chatMessageType}) async {
    // log("Chat Message Url ${RequestUrls.postChatMessage}");
    if (chatMessageDetails == null) {
      //state.value = DataState.loading;
    }

    await BaseClient(url: RequestUrls.postChatMessage, body: chatMessageDetails)
        .post(decode: true)
        .then(
      (value) {
        if (value == null) {
        } else {
          AcknowledgementResponseModel acknowledgementModel =
              AcknowledgementResponseModel.fromJson(value);
          setChatMessageDetails(acknowledgementModel: acknowledgementModel);
        }
      },
    ).catchError(
      (onError) {
        //log("Post Chat Message Details $onError ${onError?.message}");
        //errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    //state.value = DataState.complete;
  }

  setChatMessageDetails(
      {required AcknowledgementResponseModel? acknowledgementModel}) {
    if (acknowledgementModel == null) {
      return;
    }

    chatMessageAckDetails = acknowledgementModel;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST chatMessage DETAILS
    // postchatMessageDetails();
  }
}
