import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/chat/src/get_chat_messages_controller.dart';
import 'package:uhi_flutter_app/controller/chat/src/post_chat_message_controller.dart';
import 'package:uhi_flutter_app/controller/controller.dart';
import 'package:uhi_flutter_app/model/common/src/chat_message_dhp_model.dart';
import 'package:uhi_flutter_app/model/common/src/chat_message_model.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/model/response/response.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/utils/utils.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  String? doctorHprId;
  String? patientAbhaId;
  String? doctorName;
  String? doctorGender;
  String? providerUri;

  ChatPage({
    key,
    this.doctorHprId,
    this.patientAbhaId,
    this.doctorName,
    this.doctorGender,
    this.providerUri,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  ///TEXT CONTROLLERS
  final _chatMsgTextEditingController = TextEditingController();
  final _postChatMessageController = Get.put(PostChatMessageController());
  final _getChatMessageController = Get.put(GetChatMessagesController());
  final _messagesScrollController = ScrollController(keepScrollOffset: true);

  ///SCREEN WIDTH
  var width;

  ///SCREEN HEIGHT
  var height;

  ///STOMP VARIABLES
  StompClient? stompClient;

  ///DATA VARIABLES
  ResponseModel? responseModel;
  String _chatId = "";
  String _uniqueId = "";
  String? _doctorHprId = "";
  String? _patientAbhaId = "";
  String? _doctorName = "";
  String? _doctorGender = "";
  String? _providerUri = "";
  // List<ChatMessageDhpModel> _messagesList = List.empty(growable: true);
  List<ChatMessageModel> _messagesList = List.empty(growable: true);
  Future<List<ChatMessageModel>?>? futureListOfMessages;
  bool isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // _loadMessages();

    _doctorHprId = widget.doctorHprId;
    _patientAbhaId = widget.patientAbhaId;
    _doctorName = widget.doctorName;
    _doctorGender = widget.doctorGender;
    _providerUri = widget.providerUri;

    if (mounted) {
      futureListOfMessages = getChatMessages();
    }

    // if (_messagesScrollController.hasClients) {
    //   log("Scrolling");

    //   _messagesScrollController
    //       .jumpTo(_messagesScrollController.position.maxScrollExtent);
    // }

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (_messagesScrollController.hasClients) {
        log("Scrolling");

        _messagesScrollController.animateTo(
            _messagesScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeIn);
      }
    });
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    super.dispose();
  }

  ///CHAT MESSAGE HISTORY API
  Future<List<ChatMessageModel>?> getChatMessages() async {
    List<ChatMessageModel>? listOfMsgs = List.empty(growable: true);

    await _getChatMessageController.getChatMessages(
        sender: _patientAbhaId, receiver: _doctorHprId);

    if (_getChatMessageController.chatMessages != null &&
        _getChatMessageController.chatMessages!.isNotEmpty) {
      listOfMsgs.addAll(_getChatMessageController.chatMessages!);
      await connectToStomp();
    }

    return listOfMsgs;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureListOfMessages = getChatMessages();
  }

  Future<void> connectToStomp() async {
    // _uniqueId = const Uuid().v1();
    _chatId = "$_patientAbhaId|$_doctorHprId";

    log("$_chatId", name: "CHAT KEY");

    stompClient = await StompClient(
      config: StompConfig(
        url: RequestUrls.euaChatStompSocketUrl,
        // url: "ws://100.65.158.41:8903/eua-chat",
        onConnect: await onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(Duration(milliseconds: 200));
          print('connecting...');
        },
        onStompError: (dynamic error) =>
            print("On Stomp Error " + error.toString()),
        onWebSocketError: (dynamic error) {
          print("On Websocket Error " + error.toString());
        },
        onDebugMessage: (dynamic error) {
          print("On Debug Message " + error.toString());
        },
        onUnhandledFrame: (dynamic error) =>
            print("On Unhandled Frame " + error.toString()),
        onUnhandledMessage: (dynamic error) =>
            print("On Unhandled Message " + error.toString()),
        onUnhandledReceipt: (dynamic error) =>
            print("On Unhandled Receipt " + error.toString()),
        onDisconnect: (dynamic data) =>
            print("On Disconnect " + data.toString()),
        onWebSocketDone: () => log("Websocket closed"),
        stompConnectHeaders: {'chatid': _chatId},
        webSocketConnectHeaders: {'chatid': _chatId},
      ),
    );
    stompClient?.activate();
  }

  Future<void> onConnect(StompFrame frame) async {
    print("connected");
    await stompClient?.subscribe(
      destination: '/msg/queue/specific-user',
      callback: (frame) {
        if (frame.body != null) {
          log("${frame.body}", name: "FRAME BODY");
          ChatMessageDhpModel chatMessageModel =
              ChatMessageDhpModel.fromJson(json.decode(frame.body!));
          ChatMessageModel chatMessage = ChatMessageModel();
          chatMessage.sender =
              chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
          chatMessage.receiver =
              chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
          chatMessage.time =
              chatMessageModel.message?.intent?.chat?.time?.timestamp;
          chatMessage.contentId =
              chatMessageModel.message?.intent?.chat?.content?.contentId;
          chatMessage.contentValue =
              chatMessageModel.message?.intent?.chat?.content?.contentValue;

          _messagesList.add(chatMessage);
          _messagesList.sort((b, a) =>
              DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));
          _scrollToBottom();

          setState(() {});
        }
      },
    );
  }

  ///CHAT MESSAGE API
  postMessageAPI() async {
    _uniqueId = Uuid().v1();
    _postChatMessageController.refresh();
    var userData;

    await SharedPreferencesHelper.getUserData().then((value) => setState(() {
          setState(() {
            debugPrint("Printing the shared preference userData : $value");
            userData = value;
          });
        }));

    GetUserDetailsResponse? getUserDetailsResponseModel =
        GetUserDetailsResponse.fromJson(jsonDecode(userData!));

    ChatMessageDhpModel chatMessageModel = ChatMessageDhpModel();

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "on_message";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "eua-nha";
    contextModel.consumerUri = "http://100.65.158.41:8901/api/v1/euaService";
    contextModel.providerUrl = _providerUri;
    contextModel.timestamp = DateTime.now().toLocal().toUtc().toIso8601String();
    contextModel.transactionId = _uniqueId;

    ChatMessage chatMessage = ChatMessage();
    ChatIntent chatIntent = ChatIntent();
    ChatMsg chat = ChatMsg();
    Sender? sender = Sender();
    Sender? receiver = Sender();
    Person? personSender = Person();
    Person? personReceiver = Person();
    Content? content = Content();
    ChatTime? time = ChatTime();

    time.timestamp = DateFormat("y-MM-ddTHH:mm:ss").format(DateTime.now());

    content.contentId = _uniqueId; //Uuid
    content.contentValue = _chatMsgTextEditingController.text.isNotEmpty
        ? _chatMsgTextEditingController.text.trim()
        : "";

    personSender.cred = _patientAbhaId; //Sender hpr/abha id
    personSender.name = getUserDetailsResponseModel.fullName;
    personSender.gender = getUserDetailsResponseModel.gender;
    personSender.image = getUserDetailsResponseModel.profilePhoto;
    sender.person = personSender;

    personReceiver.cred = _doctorHprId; //Receiver hpr/abha id
    personReceiver.name = _doctorName;
    personReceiver.gender = _doctorGender;
    personReceiver.image = "image";
    receiver.person = personReceiver;

    chat.time = time;
    chat.content = content;
    chat.sender = sender;
    chat.receiver = receiver;

    chatIntent.chat = chat;
    chatMessage.intent = chatIntent;

    chatMessageModel.context = contextModel;
    chatMessageModel.message = chatMessage;

    log("${jsonEncode(chatMessageModel)}", name: "CHAT MESSAGE MODEL");

    await _postChatMessageController.postChatMessageDetails(
        chatMessageDetails: chatMessageModel);

    if (_postChatMessageController
            .chatMessageAckDetails?.message?.ack?.status ==
        "ACK") {
      ChatMessageModel chatMessage = ChatMessageModel();

      chatMessage.sender =
          chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
      chatMessage.receiver =
          chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
      chatMessage.time =
          chatMessageModel.message?.intent?.chat?.time?.timestamp;
      chatMessage.contentId =
          chatMessageModel.message?.intent?.chat?.content?.contentId;
      chatMessage.contentValue =
          chatMessageModel.message?.intent?.chat?.content?.contentValue;
      _messagesList.add(chatMessage);
      _messagesList.sort(
          (b, a) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));
      _chatMsgTextEditingController.clear();
      _scrollToBottom();

      setState(() {
        isLoading = false;
      });
    } else if (_postChatMessageController
            .chatMessageAckDetails?.message?.ack?.status ==
        "NACK") {
      setState(() {
        isLoading = false;
      });
      DialogHelper.showErrorDialog(description: "Message not sent.");
    } else if (_postChatMessageController.errorString.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      DialogHelper.showErrorDialog(description: "Message not sent.");
    } else {
      setState(() {
        isLoading = false;
      });
      DialogHelper.showErrorDialog(description: "Message not sent.");
    }
  }

  _scrollToBottom() {
    if (_messagesScrollController.hasClients) {
      log("Scrolling");
      _messagesScrollController.animateTo(
          _messagesScrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.darkGrey323232,
            size: 32,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: Image.network(_doctorGender == "M"
                      ? AppStrings().maleDoctorImage
                      : AppStrings().femaleDoctorImage)
                  .image,
              // backgroundImage: Image.network(
              //   AppStrings.femaleDoctorImage,
              //   fit: BoxFit.fill,
              // ).image,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                _doctorName ?? "Doctor",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: futureListOfMessages,
        builder: (context, loadingData) {
          switch (loadingData.connectionState) {
            case ConnectionState.waiting:
              return CommonLoadingIndicator();

            case ConnectionState.active:
              return Text(AppStrings().loadingData);

            case ConnectionState.done:
              return loadingData.data != null
                  ? buildWidgets(loadingData.data as List<ChatMessageModel>)
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: Stack(
                        children: [
                          ListView(),
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Center(
                              child: Text(
                                AppStrings().serverBusyErrorMsg,
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            default:
              return loadingData.data != null
                  ? buildWidgets(loadingData.data as List<ChatMessageModel>)
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: Stack(
                        children: [
                          ListView(),
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Center(
                              child: Text(
                                AppStrings().serverBusyErrorMsg,
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
          }
        },
      ),

      // body: Container(
      //   width: width,
      //   height: height,
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       ///MESSAGES
      //       Expanded(
      //         child: ListView.builder(
      //           // itemCount: 5,
      //           itemCount: _messagesList.length,
      //           padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      //           itemBuilder: (context, index) {
      //             // if (index == 0) {
      //             //   return buildSenderMessage(text: "Hello Doctor!");
      //             // } else if (index == 1) {
      //             //   return buildReceiverMessage(
      //             //       text: "Hello Dear, How may I help you?");
      //             // } else if (index == 2) {
      //             //   return buildSenderMessage(
      //             //       text: "I am Suffering from, chest pain and mild fever");
      //             // } else if (index == 3) {
      //             //   return buildReceiverMessage(
      //             //       text: "Since when you are Having this problem?");
      //             // } else {
      //             //   return Container();
      //             // }
      //             log("${_messagesList[index].message?.intent?.chat?.sender?.person?.cred}",
      //                 name: "MESSAGE");

      //             if (_messagesList[index]
      //                     .message
      //                     ?.intent
      //                     ?.chat
      //                     ?.sender
      //                     ?.person
      //                     ?.cred ==
      //                 _patientAbhaId) {
      //               return buildSenderMessage(
      //                   text: _messagesList[index]
      //                           .message
      //                           ?.intent
      //                           ?.chat
      //                           ?.content
      //                           ?.contentValue ??
      //                       "");
      //             } else if (_messagesList[index]
      //                     .message
      //                     ?.intent
      //                     ?.chat
      //                     ?.receiver
      //                     ?.person
      //                     ?.cred ==
      //                 _patientAbhaId) {
      //               return buildReceiverMessage(
      //                   text: _messagesList[index]
      //                           .message
      //                           ?.intent
      //                           ?.chat
      //                           ?.content
      //                           ?.contentValue ??
      //                       "");
      //             } else {
      //               return Container();
      //             }
      //           },
      //         ),
      //       ),

      //       ///TYPE A MESSAGE
      //       Container(
      //         width: width,
      //         height: height * 0.08,
      //         padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      //         decoration: const BoxDecoration(
      //           color: Colors.white,
      //           boxShadow: [
      //             BoxShadow(
      //               offset: Offset(0, 10),
      //               blurRadius: 20,
      //               color: Color(0x1B1C204D),
      //             )
      //           ],
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Expanded(
      //               child: TextField(
      //                 controller: _chatMsgTextEditingController,
      //                 decoration: InputDecoration(
      //                   hintText: "Write Message",
      //                   border: InputBorder.none,
      //                 ),
      //               ),
      //             ),
      //             GestureDetector(
      //               onTap: () {
      //                 setState(() {
      //                   isLoading = true;
      //                 });
      //                 postMessageAPI();
      //               },
      //               child: Container(
      //                 width: width * 0.14,
      //                 child: Center(
      //                     child: isLoading
      //                         ? SizedBox(
      //                             width: 15,
      //                             height: 15,
      //                             child: CircularProgressIndicator(
      //                               color: AppColors.primaryLightBlue007BFF,
      //                               value: 20,
      //                             ),
      //                           )
      //                         : Text(
      //                             "Send",
      //                             style: TextStyle(
      //                               color: Color(0xFF334856),
      //                               fontSize: 16,
      //                               fontWeight: FontWeight.bold,
      //                             ),
      //                           )),
      //               )
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  buildWidgets(List<ChatMessageModel>? data) {
    if (data != null && _messagesList.isEmpty) {
      _messagesList.addAll(data);
      _messagesList.sort(
          (b, a) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));
      // _messagesList.reversed;
      // _scrollToBottom();
      log("${json.encode(_messagesList)}", name: "MESSAGES");
    }

    return Container(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///MESSAGES
          Expanded(
            child: ListView.builder(
              // itemCount: 5,
              itemCount: _messagesList.length,
              // shrinkWrap: true,
              reverse: true,
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
              controller: _messagesScrollController,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                // if (index == 0) {
                //   return buildSenderMessage(text: "Hello Doctor!");
                // } else if (index == 1) {
                //   return buildReceiverMessage(
                //       text: "Hello Dear, How may I help you?");
                // } else if (index == 2) {
                //   return buildSenderMessage(
                //       text: "I am Suffering from, chest pain and mild fever");
                // } else if (index == 3) {
                //   return buildReceiverMessage(
                //       text: "Since when you are Having this problem?");
                // } else {
                //   return Container();
                // }
                // log("${_messagesList[index].contentValue}", name: "MESSAGE");

                if (_messagesList[index].sender == _patientAbhaId) {
                  return buildSenderMessage(
                      text: _messagesList[index].contentValue ?? "");
                } else if (_messagesList[index].receiver == _patientAbhaId) {
                  return buildReceiverMessage(
                      text: _messagesList[index].contentValue ?? "");
                } else {
                  return Container();
                }
              },
            ),
          ),

          ///TYPE A MESSAGE
          // Container(
          //   width: width,
          //   height: height * 0.08,
          //   padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          //   decoration: const BoxDecoration(
          //     color: Colors.white,
          //     boxShadow: [
          //       BoxShadow(
          //         offset: Offset(0, 10),
          //         blurRadius: 20,
          //         color: Color(0x1B1C204D),
          //       )
          //     ],
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           controller: _chatMsgTextEditingController,
          //           maxLines: 4,
          //           decoration: InputDecoration(
          //             hintText: "Write Message",
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //       GestureDetector(
          //         onTap: isLoading
          //             ? null
          //             : () {
          //                 setState(() {
          //                   isLoading = true;
          //                 });
          //                 postMessageAPI();
          //               },
          //         child: Container(
          //           width: width * 0.14,
          //           child: Center(
          //               child: isLoading
          //                   ? SizedBox(
          //                       width: 15,
          //                       height: 15,
          //                       child: CircularProgressIndicator(
          //                         color: AppColors.primaryLightBlue007BFF,
          //                         value: 20,
          //                       ),
          //                     )
          //                   : Text(
          //                       "Send",
          //                       style: TextStyle(
          //                         color: Color(0xFF334856),
          //                         fontSize: 16,
          //                         fontWeight: FontWeight.bold,
          //                       ),
          //                     )),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          generateBottomWidget()
        ],
      ),
    );
  }

  generateBottomWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
      color: AppColors.tileColors,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 20,
                    color: Color(0x1B1C204D),
                  )
                ],
              ),
              child: TextField(
                controller: _chatMsgTextEditingController,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                    hintText: "Write Message",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 8, right: 8)),
              ),
            ),
          ),
          Center(
            child: isLoading
                ? Container(
                    padding: const EdgeInsets.all(8),
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      if (_chatMsgTextEditingController.text
                          .trim()
                          .isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        postMessageAPI();
                      } else {}
                    },
                    icon: Icon(
                      Icons.send,
                      color: AppColors.white,
                      size: 32,
                    ),
                  )
            /*TextButton(
                  onPressed: () {
                    if (_chatMsgTextEditingController.text.trim().isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });
                      postMessageAPI();
                    } else {
                    }
                  },
                  child: Text(AppStrings().btnSend,
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.white, fontSize: 16)),
                )*/
            ,
          ),
        ],
      ),
    );
  }

  buildReceiverMessage({required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints:
              BoxConstraints(minWidth: width * 0.12, maxWidth: width * 0.7),
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: const Color(0xFF264488),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                  //bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16))),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  buildSenderMessage({required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints:
              BoxConstraints(minWidth: width * 0.12, maxWidth: width * 0.7),
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: const Color(0xFFE9ECF3),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16))),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF264488),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) => Scaffold(
  //       body: Chat(
  //         messages: _messages,
  //         onAttachmentPressed: null, //_handleAtachmentPressed,
  //         onMessageTap: _handleMessageTap,
  //         onPreviewDataFetched: _handlePreviewDataFetched,
  //         onSendPressed: _handleSendPressed,
  //         showUserAvatars: true,
  //         showUserNames: true,
  //         user: _user,
  //         customDateHeaderText: _handleCustomDateHeaderText,
  //       ),
  //     );

  // void _addMessage(types.Message message) {
  //   setState(() {
  //     _messages.insert(0, message);
  //   });
  // }

  // void _handleAtachmentPressed() {
  //   showModalBottomSheet<void>(
  //     context: context,
  //     builder: (BuildContext context) => SafeArea(
  //       child: SizedBox(
  //         height: 144,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 // _handleImageSelection();
  //               },
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('Photo'),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 _handleFileSelection();
  //               },
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('File'),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Align(
  //                 alignment: AlignmentDirectional.centerStart,
  //                 child: Text('Cancel'),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void _handleFileSelection() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     final message = types.FileMessage(
  //       author: _user,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       id: const Uuid().v4(),
  //       mimeType: lookupMimeType(result.files.single.path!),
  //       name: result.files.single.name,
  //       size: result.files.single.size,
  //       uri: result.files.single.path!,
  //     );

  //     _addMessage(message);
  //   }
  // }

  // void _handleImageSelection() async {
  //   final result = await ImagePicker().pickImage(
  //     imageQuality: 70,
  //     maxWidth: 1440,
  //     source: ImageSource.gallery,
  //   );

  //   if (result != null) {
  //     final bytes = await result.readAsBytes();
  //     final image = await decodeImageFromList(bytes);

  //     final message = types.ImageMessage(
  //       author: _user,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       height: image.height.toDouble(),
  //       id: const Uuid().v4(),
  //       name: result.name,
  //       size: bytes.length,
  //       uri: result.path,
  //       width: image.width.toDouble(),
  //     );

  //     _addMessage(message);
  //   }
  // }

  // void _handleMessageTap(BuildContext _, types.Message message) async {
  //   if (message is types.FileMessage) {
  //     var localPath = message.uri;

  //     if (message.uri.startsWith('http')) {
  //       try {
  //         final index =
  //             _messages.indexWhere((element) => element.id == message.id);
  //         final updatedMessage =
  //             (_messages[index] as types.FileMessage).copyWith(
  //           isLoading: true,
  //         );

  //         setState(() {
  //           _messages[index] = updatedMessage;
  //         });

  //         final client = http.Client();
  //         final  = await client.get(Uri.parse(message.uri));
  //         final bytes = .bodyBytes;
  //         final documentsDir = (await getApplicationDocumentsDirectory()).path;
  //         localPath = '$documentsDir/${message.name}';

  //         if (!File(localPath).existsSync()) {
  //           final file = File(localPath);
  //           await file.writeAsBytes(bytes);
  //         }
  //       } finally {
  //         final index =
  //             _messages.indexWhere((element) => element.id == message.id);
  //         final updatedMessage =
  //             (_messages[index] as types.FileMessage).copyWith(
  //           isLoading: null,
  //         );

  //         setState(() {
  //           _messages[index] = updatedMessage;
  //         });
  //       }
  //     }

  //     await OpenFile.open(localPath);
  //   }
  // }

  // void _handlePreviewDataFetched(
  //   types.TextMessage message,
  //   types.PreviewData previewData,
  // ) {
  //   final index = _messages.indexWhere((element) => element.id == message.id);
  //   final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
  //     previewData: previewData,
  //   );

  //   setState(() {
  //     _messages[index] = updatedMessage;
  //   });
  // }

  // void _handleSendPressed(types.PartialText message) {
  //   final textMessage = types.TextMessage(
  //     author: _user,
  //     createdAt: DateTime.now().millisecondsSinceEpoch,
  //     id: const Uuid().v4(),
  //     text: message.text,
  //   );

  //   _addMessage(textMessage);
  // }

  // void _loadMessages() async {
  //   final response = await rootBundle.loadString('assets/messages.json');
  //   final messages = (jsonDecode(response) as List)
  //       .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
  //       .toList();

  //   setState(() {
  //     _messages = messages;
  //   });
  // }

  // String _handleCustomDateHeaderText(DateTime dateTime) {
  //   String date = '';
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //   final yesterday = DateTime(now.year, now.month, now.day - 1);
  //   final aDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
  //   if (aDate == today) {
  //     date = 'Today, ' + DateFormat('hh:mm aa').format(dateTime);
  //   } else if (aDate == yesterday) {
  //     date = 'Yesterday, ' + DateFormat('hh:mm aa').format(dateTime);
  //   } else {
  //     date = DateFormat('MMM dd, hh:mm aa').format(dateTime);
  //   }
  //   return date;
  // }
}
