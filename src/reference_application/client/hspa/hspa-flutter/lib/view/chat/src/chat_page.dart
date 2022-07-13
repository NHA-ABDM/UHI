import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uuid/uuid.dart';

import '../../../common/src/dialog_helper.dart';
import '../../../constants/src/request_urls.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/get_chat_messages_controller.dart';
import '../../../controller/src/post_chat_message_controller.dart';
import '../../../model/src/chat_message_dhp_model.dart';
import '../../../model/src/chat_message_model.dart';
import '../../../model/src/context_model.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class ChatPage extends StatefulWidget {
  final String? doctorHprId;
  final String? patientAbhaId;
  final String? patientName;
  final String? patientGender;
  final bool allowSendMessage;
  //String? providerUri;

  const ChatPage({
    key,
    required this.doctorHprId,
    required this.patientAbhaId,
    required this.patientName,
    required this.patientGender,
    this.allowSendMessage = true
    //this.providerUri,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  ///TEXT CONTROLLERS
  final _chatMsgTextEditingController = TextEditingController();
  final _postChatMessageController = Get.put(PostChatMessageController());
  final _getChatMessageController = Get.put(GetChatMessagesController());
  final _messagesScrollController = ScrollController();

  ///SCREEN WIDTH
  var width;

  ///STOMP VARIABLES
  StompClient? stompClient;

  ///DATA VARIABLES
  // ResponseModel? responseModel;
  String _chatId = "";
  String _uniqueId = "";
  String? _doctorHprId = "";
  String? _patientAbhaId = "";
  String? _doctorName = "";
  //String? _providerUri = "";
  // List<ChatMessageDhpModel> _messagesList = List.empty(growable: true);
  final List<ChatMessageModel> _messagesList = <ChatMessageModel>[];
  Future<List<ChatMessageModel>?>? futureListOfMessages;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    // _loadMessages();

    _doctorHprId = widget.doctorHprId;
    _patientAbhaId = widget.patientAbhaId;
    _doctorName = widget.patientName;
    //_providerUri = widget.providerUri;

    if (mounted) {
      futureListOfMessages = getChatMessages();
    }

  }

  @override
  void dispose() {
    _chatMsgTextEditingController.dispose();
    _messagesScrollController.dispose();
    stompClient?.deactivate();
    super.dispose();
  }

  ///CHAT MESSAGE HISTORY API
  Future<List<ChatMessageModel>?> getChatMessages() async {
    List<ChatMessageModel>? listOfMsgs = List.empty(growable: true);

    await _getChatMessageController.getChatMessages(
        sender: _doctorHprId, receiver: _patientAbhaId);

    debugPrint('Chat messages are ${_getChatMessageController.chatMessages}');
    if (_getChatMessageController.chatMessages != null) {
      listOfMsgs.addAll(_getChatMessageController.chatMessages!);
      //connectToStomp();
    }
    await connectToStomp();

    return listOfMsgs;
  }

  Future<void> onRefresh() async {
    setState(() {});
    futureListOfMessages = getChatMessages();
  }

  connectToStomp() async {
    // _uniqueId = const Uuid().v1();
    _chatId = "$_patientAbhaId|$_doctorHprId";

    debugPrint('chat key is $_chatId');

    stompClient = StompClient(
      config: StompConfig(
        url: RequestUrls.euaChatStompSocketUrl,
        // url: "ws://100.65.158.41:8903/eua-chat",
        onConnect: onConnect,
        beforeConnect: () async {
          debugPrint('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          debugPrint('connecting...');
        },
        onStompError: (dynamic error) =>
            debugPrint("On Stomp Error " + error.toString()),
        onWebSocketError: (dynamic error) {
          debugPrint("On Websocket Error " + error.toString());
        },
        onDebugMessage: (dynamic error) {
          debugPrint("On Debug Message " + error.toString());
        },
        onUnhandledFrame: (dynamic error) =>
            debugPrint("On Unhandled Frame " + error.toString()),
        onUnhandledMessage: (dynamic error) =>
            debugPrint("On Unhandled Message " + error.toString()),
        onUnhandledReceipt: (dynamic error) =>
            debugPrint("On Unhandled Receipt " + error.toString()),
        onDisconnect: (dynamic data) =>
            debugPrint("On Disconnect " + data.toString()),
        onWebSocketDone: () => log("Websocket closed"),
        stompConnectHeaders: {'chatid': _chatId},
        webSocketConnectHeaders: {'chatid': _chatId},
      ),
    );
    stompClient?.activate();
  }

  Future<void> onConnect(StompFrame frame) async {
    debugPrint("connected");
    stompClient?.subscribe(
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

          setState(() {
            _messagesList.add(chatMessage);
            sortList();
          });
          _postChatMessageController.refresh();
        }
      },
    );
  }

  ///CHAT MESSAGE API
  postMessageAPI() async {
    _uniqueId = const Uuid().v1();
    _postChatMessageController.refresh();

    ChatMessageDhpModel chatMessageModel = ChatMessageDhpModel();

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "message";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "https://exampleapp.io/";
    contextModel.consumerUri = "http://100.65.158.41:8903/api/v1/bookingService";
    //contextModel.providerUrl = _providerUri;
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

    personSender.cred = _doctorHprId; //Sender hpr/abha id
    sender.person = personSender;

    personReceiver.cred = _patientAbhaId; //Receiver hpr/abha id
    receiver.person = personReceiver;

    chat.time = time;
    chat.content = content;
    chat.sender = sender;
    chat.receiver = receiver;

    chatIntent.chat = chat;
    chatMessage.intent = chatIntent;

    chatMessageModel.context = contextModel;
    chatMessageModel.message = chatMessage;

    log(jsonEncode(chatMessageModel), name: "CHAT MESSAGE MODEL");

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

      setState(() {
        _messagesList.add(chatMessage);
        sortList();
        _chatMsgTextEditingController.clear();
        isLoading = false;
      });
      _postChatMessageController.refresh();
    } else if (_postChatMessageController
            .chatMessageAckDetails?.message?.ack?.status ==
        "NACK") {
      setState(() {
        isLoading = false;
      });
      DialogHelper.showErrorDialog(description: "Message not sent 1.");
    } else if (_postChatMessageController.errorString.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      DialogHelper.showErrorDialog(description: "Message not sent 2.");
    } else {
      setState(() {
        isLoading = false;
      });
      DialogHelper.showErrorDialog(description: "Message not sent 3.");
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
        ),
        title: Text(
          _doctorName ?? "Patient",
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.textBoldStyle(fontSize: 18, color: AppColors.black),
        ),
      ),
      body: SafeArea(
        left: false,
        right: false,
        top: false,
        child: FutureBuilder(
          future: futureListOfMessages,
          builder: (context, loadingData) {
            switch (loadingData.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());

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
                              padding: const EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  AppStrings().noDataAvailable,
                                  style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.black),
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
                              padding: const EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  AppStrings().noDataAvailable,
                                  style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.black),
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
      ),
    );
  }

  void sortList() {
    if(_messagesList.isNotEmpty) {
    _messagesList.sort(
    (b, a) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));
    }
  }

  buildWidgets(List<ChatMessageModel>? data) {
    if (data != null && _messagesList.isEmpty) {
      _messagesList.addAll(data);
      _messagesList.sort(
          (b, a) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));
      log(json.encode(_messagesList), name: "MESSAGES");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            color: AppColors.white,
            child: ListView.builder(
              itemCount: _messagesList.length,
              //shrinkWrap: true,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              controller: _messagesScrollController,
              itemBuilder: (context, index) {
                if (_messagesList[index].sender == _doctorHprId) {
                  return buildSenderMessage(
                      text: _messagesList[index].contentValue ?? "");
                } else if (_messagesList[index].receiver == _doctorHprId) {
                  return buildReceiverMessage(
                      text: _messagesList[index].contentValue ?? "");
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
        if(widget.allowSendMessage) generateBottomWidget()
      ],
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
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.senderBackColor,
            // borderRadius: BorderRadius.circular(8),
            borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16), bottomRight: Radius.circular(16))
          ),
          child: Text(
            text,
            style: AppTextStyle.textSemiBoldStyle(color: AppColors.senderTextColor, fontSize: 14),
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
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.tileColors,
            // borderRadius: BorderRadius.circular(8),
              borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))
          ),
          child: Text(
            text,
            style: AppTextStyle.textSemiBoldStyle(color: AppColors.white, fontSize: 14),
          ),
        ),
      ],
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
                  contentPadding: EdgeInsets.only(left: 8, right: 8)
                ),
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
                      if (_chatMsgTextEditingController.text.trim().isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        postMessageAPI();
                      } else {
                      }
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
                  )*/,
          ),
        ],
      ),
    );
  }
}
