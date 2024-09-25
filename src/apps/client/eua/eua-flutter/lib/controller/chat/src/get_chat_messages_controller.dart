import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/common/src/chat_message_model.dart';
import 'package:uhi_flutter_app/services/services.dart';
import 'package:uhi_flutter_app/model/model.dart';

///TO CHANGE STATE OF UI
// enum DataState { loading, complete }

class GetChatMessagesController extends GetxController with ExceptionHandler {
  ///CHAT MESSAGES
  List<ChatMessageModel>? chatMessages;

  ///STATE
  var state = DataState.loading.obs;

  ///ERROR STRING
  var errorString = '';

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getChatMessages({String? sender, String? receiver}) async {
    await BaseClient(url: "${RequestUrls.getChatMessages}/$sender/$receiver")
        .get()
        .then(
      (value) {
        if (value == null) {
        } else {
          List tmpList = value;
          List<ChatMessageModel> messages = List.empty(growable: true);

          tmpList.forEach((element) {
            ChatMessageModel chatMessageModel =
                ChatMessageModel.fromJson(element);
            messages.add(chatMessageModel);
          });

          setChatMessages(listOfMessages: messages);
        }
      },
    ).catchError(
      (onError) {
        // log("Post Chat Message Details $onError ${onError.message}");
        // errorString = "${onError.message}";
        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );

    state.value = DataState.complete;
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
