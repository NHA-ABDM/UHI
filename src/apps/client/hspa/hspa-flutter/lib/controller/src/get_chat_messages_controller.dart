

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/src/request_urls.dart';
import '../../model/src/chat_message_model.dart';
import '../../services/services.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class GetChatMessagesController extends GetxController with ExceptionHandler {
  ///CHAT MESSAGES
  List<ChatMessageModel>? chatMessages;

  ///STATE
  // var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';


  Future<void> getChatMessages({String? sender, String? receiver}) async {
    debugPrint('In getChatMessages  $sender and $receiver');
    await BaseClient(url: "${RequestUrls.getChatMessages}/$sender/$receiver")
        .get(decode: true)
        .then(
      (value) {
        if (value == null) {
          debugPrint('In value is null  $value');
        } else {
          //var responseJson = json.decode(utf8.decode(value.bodyBytes));
          List tmpList = value;
          List<ChatMessageModel> messages = List.empty(growable: true);

          for (var element in tmpList) {
            debugPrint('In list for each $element');
            ChatMessageModel chatMessageModel =
                ChatMessageModel.fromJson(element);
            messages.add(chatMessageModel);
          }

          setChatMessages(listOfMessages: messages);
        }
      },
    ).catchError(
      (onError) {
        debugPrint('In getChatMessages on error');
        // log("Post Chat Message Details $onError ${onError.message}");
        // errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    //state.value = DataState.complete;
  }

  setChatMessages({required List<ChatMessageModel>? listOfMessages}) {
    if (listOfMessages == null) {
      return;
    }

    chatMessages = listOfMessages;
  }

  @override
  refresh() async {
    errorString = '';

    ///POST chatMessage DETAILS
    // postchatMessageDetails();
  }
}
