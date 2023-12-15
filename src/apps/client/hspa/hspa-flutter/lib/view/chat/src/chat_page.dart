import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/settings/src/preferences.dart';
import 'package:hspa_app/utils/src/utility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uuid/uuid.dart';

import '../../../common/src/dialog_helper.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/request_urls.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/get_chat_messages_controller.dart';
import '../../../controller/src/get_shared_key_controller.dart';
import '../../../controller/src/post_chat_message_controller.dart';
import '../../../model/response/src/get_shared_key_response_model.dart';
import '../../../model/src/chat_message_dhp_model.dart';
import '../../../model/src/chat_message_model.dart';
import '../../../model/src/context_model.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/vertical_spacing.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {

  ///TEXT CONTROLLERS
  final _chatMsgTextEditingController = TextEditingController();
  final _postChatMessageController = Get.put(PostChatMessageController());
  final _getChatMessageController = Get.put(GetChatMessagesController());
  final _messagesScrollController = ScrollController();
  final _getSharedKeyController = Get.put(GetSharedKeyController());

  ///SCREEN WIDTH
  var width;

  ///STOMP VARIABLES
  StompClient? stompClient;

  ///DATA VARIABLES
  // ResponseModel? responseModel;
  String _chatId = "";
  String _uniqueId = "";

  /// Arguments
  bool allowSendMessage = true;
  String? doctorHprId = "";
  String? patientAbhaId = "";
  String? patientGender = "";
  String? patientName = "";

  //String? _providerUri = "";
  // List<ChatMessageDhpModel> _messagesList = List.empty(growable: true);
  final List<ChatMessageModel> _messagesList = <ChatMessageModel>[];
  Future<List<ChatMessageModel>?>? futureListOfMessages;
  bool isLoading = false;
  DoctorProfile? _profile;

  ///Encryption
  SecretKey? _sharedSecretKey;
  SecretBox? _secretBox;
  String? _privateKey;
  GetSharedKeyResponseModel? _getSharedKeyResponse;
  /// Generate a key pair.
  final encryptionAlgorithm = X25519();
  ///Encryption algorithm
  final algorithm = AesCtr.with256bits(macAlgorithm: Hmac.sha256());

  ///FILE SHARING
  String? _fileName;
  String? base64EncodeFile;

  @override
  void initState() {

    doctorHprId = Get.arguments['doctorHprId'];
    patientAbhaId = Get.arguments['patientAbhaId'];
    patientGender = Get.arguments['patientGender'];
    patientName = Get.arguments['patientName'];

    _privateKey = Preferences.getString(key: AppStrings.encryptionPrivateKey);

    if(Get.arguments['allowSendMessage'] != null){
      allowSendMessage = Get.arguments['allowSendMessage'];
    }

    getDoctorProfile();
    super.initState();
    // _loadMessages();
    //_providerUri = widget.providerUri;

    if (mounted) {
      futureListOfMessages = getChatMessages();
    }
  }

  Future<void> getDoctorProfile() async {
    _profile = await DoctorProfile.getSavedProfile();
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

    await _getSharedKeyController.getSharedKeyDetails(
        doctorId: doctorHprId, patientId: patientAbhaId);

    if (_getSharedKeyController.sharedKeyDetails == null ||
        _getSharedKeyController.sharedKeyDetails.isEmpty) {
    } else {
      _getSharedKeyResponse = GetSharedKeyResponseModel.fromJson(
          json.decode(_getSharedKeyController.sharedKeyDetails)[0]);

      if (_getSharedKeyResponse?.publicKey != null &&
          _getSharedKeyResponse?.publicKey != "") {
        
        _sharedSecretKey = await Utility.getSecretKey(publicKey: _getSharedKeyResponse!.publicKey!, privateKey: _privateKey!);
        
        /*List<int> publicKeyBytes =
        (jsonDecode(_getSharedKeyResponse!.publicKey!) as List)
            .map((e) => int.parse(e.toString()))
            .toList();

        List<int> privateKeyBytes = (jsonDecode(_privateKey!) as List)
            .map((e) => int.parse(e.toString()))
            .toList();

        debugPrint("$privateKeyBytes PRIVATE KEY");

        final doctorPublicKey =
        SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519);

        final keyPair = SimpleKeyPairData(privateKeyBytes,
            publicKey: doctorPublicKey, type: KeyPairType.x25519);

        _sharedSecretKey = await encryptionAlgorithm.sharedSecretKey(
            keyPair: keyPair, remotePublicKey: doctorPublicKey);*/

        debugPrint('Secret key is ${await _sharedSecretKey?.extractBytes()}');
      }

      await _getChatMessageController.getChatMessages(
          sender: doctorHprId, receiver: patientAbhaId);

      if (_getChatMessageController.chatMessages != null &&
          _getChatMessageController.chatMessages!.isNotEmpty) {
        List<ChatMessageModel> tmpList = List.empty(growable: true);
        _getChatMessageController.chatMessages?.forEach((element) async {
          ChatMessageModel chatMessageModel = ChatMessageModel();

          debugPrint('Content type is ${element.contentType}');

          if(element.contentType != null && element.contentType == 'text') {
            String? message;
            if(element.contentValue != null && element.contentValue!.contains('cipher_text')) {
              message = await Utility.decryptMessage(
                  message: element.contentValue!, secretKey: _sharedSecretKey!);
            } else {
              message = element.contentValue ?? '';
            }
            chatMessageModel.contentValue = message;
          } if(element.contentType != null && element.contentType == 'media') {
            chatMessageModel.contentValue = '';
            chatMessageModel.contentUrl = element.contentUrl;
          }

          chatMessageModel.sender = element.sender;
          chatMessageModel.receiver = element.receiver;
          chatMessageModel.consumerUrl = element.consumerUrl;
          chatMessageModel.providerUrl = element.providerUrl;
          chatMessageModel.time = element.time;
          chatMessageModel.contentId = element.contentId;
          chatMessageModel.contentType = element.contentType;

          debugPrint("${jsonEncode(chatMessageModel)} LIST");

          tmpList.add(chatMessageModel);
        });
        debugPrint("${jsonEncode(tmpList)} LIST");
        await Future.delayed(const Duration(milliseconds: 800));
        listOfMsgs.addAll(tmpList);
        await connectToStomp();
      }
    }

    return listOfMsgs;
  }

/*  Future<String?> _encryptMessage({required String message}) async {
    ///Message we want to encrypt
    final utfEncodedMessage = utf8.encode(message);

    ///Encrypt
    _secretBox = await algorithm.encrypt(
      utfEncodedMessage,
      secretKey: _sharedSecretKey!,
    );

    ChatMessageEncryptionModel chatMessageEncryptionModel =
    ChatMessageEncryptionModel();
    chatMessageEncryptionModel.cipherText = _secretBox?.cipherText;
    chatMessageEncryptionModel.nonce = _secretBox?.nonce;
    chatMessageEncryptionModel.macBytes = _secretBox?.mac.bytes;

    return jsonEncode(chatMessageEncryptionModel);
  }

  Future<String?> _decryptMessage({required String message}) async {
    debugPrint('Message to decrypt is $message');
    String decryptedMessage;
    List<int> encodedText;

    ChatMessageEncryptionModel chatMessageEncryptionModel =
    ChatMessageEncryptionModel.fromJson(jsonDecode(message));

    SecretBox secretBox = SecretBox(chatMessageEncryptionModel.cipherText!,
        nonce: chatMessageEncryptionModel.nonce!,
        mac: Mac(chatMessageEncryptionModel.macBytes!));

    ///Decrypt
    encodedText = await algorithm.decrypt(
      secretBox,
      secretKey: _sharedSecretKey!,
    );

    decryptedMessage = utf8.decode(encodedText);

    return decryptedMessage;
  }*/

  Future<void> onRefresh() async {
    setState(() {});
    futureListOfMessages = getChatMessages();
  }

  connectToStomp() async {
    // _uniqueId = const Uuid().v1();
    _chatId = "$patientAbhaId|$doctorHprId";

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
      callback: (frame) async {
        if (frame.body != null) {
          log("${frame.body}", name: "FRAME BODY");
          ChatMessageDhpModel chatMessageModel =
              ChatMessageDhpModel.fromJson(json.decode(frame.body!));
          ChatMessageModel chatMessage = await getChatMessageObject(chatMessageModel);

          /*chatMessage.sender =
              chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
          chatMessage.receiver =
              chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
          chatMessage.time =
              chatMessageModel.message?.intent?.chat?.time?.timestamp;
          chatMessage.contentId =
              chatMessageModel.message?.intent?.chat?.content?.contentId;
          chatMessage.contentValue = await Utility.decryptMessage(
              message: chatMessageModel
                  .message?.intent?.chat?.content?.contentValue ??
                  "", secretKey: _sharedSecretKey!);*/

          setState(() {
            _messagesList.add(chatMessage);
            sortList();
          });
          _postChatMessageController.refresh();
        }
      },
    );
  }

  Future<ChatMessageModel> getChatMessageObject(ChatMessageDhpModel chatMessageModel) async{
    ChatMessageModel chatMessage = ChatMessageModel();
    chatMessage.sender =
        chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
    chatMessage.receiver =
        chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
    chatMessage.time =
        chatMessageModel.message?.intent?.chat?.time?.timestamp;
    chatMessage.contentId =
        chatMessageModel.message?.intent?.chat?.content?.contentId;

    chatMessage.contentType = chatMessageModel.message?.intent?.chat?.content?.contentType;

    if(chatMessage.contentType != null && chatMessage.contentType == 'text') {
      String? contentValue = chatMessageModel.message?.intent?.chat?.content?.contentValue;
      if(contentValue != null && contentValue.contains('cipher_text')) {
        chatMessage.contentValue = await Utility.decryptMessage(
            message: chatMessageModel
                .message?.intent?.chat?.content?.contentValue ??
                "", secretKey: _sharedSecretKey!);
      } else {
        chatMessage.contentValue = contentValue;
      }
    } if(chatMessage.contentType != null && chatMessage.contentType == 'media') {
      chatMessage.contentValue = '';
      String? contentValue = chatMessageModel.message?.intent?.chat?.content?.contentValue;
      if(contentValue != null && contentValue.isNotEmpty) {
        chatMessage.contentUrl =
            chatMessageModel.message?.intent?.chat?.content?.contentValue;
      } else {
        chatMessage.contentUrl = chatMessageModel
            .message?.intent?.chat?.content?.contentUrl;
      }
    }
    return chatMessage;
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
    contextModel.consumerUri = RequestUrls.consumerUri;
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

    if (base64EncodeFile != null && base64EncodeFile!.isNotEmpty) {
      content.contentValue = base64EncodeFile;
      content.contentType = 'media';
      content.contentFilename = _fileName ?? 'img';
    } else {
      String? encryptedMessage = await Utility.encryptMessage(
          message: _chatMsgTextEditingController.text.isNotEmpty
              ? _chatMsgTextEditingController.text.trim()
              : "", secretKey: _sharedSecretKey!);

      ///Encrypted message
      content.contentValue = "$encryptedMessage";
      content.contentType = 'text';
    }

    /*content.contentValue = _chatMsgTextEditingController.text.isNotEmpty
        ? _chatMsgTextEditingController.text.trim()
        : "";*/

    personSender.cred = doctorHprId; //Sender hpr/abha id
    personSender.name = _profile?.displayName;
    personSender.gender = _profile?.gender;
    personSender.image = _profile?.profilePhoto;
    sender.person = personSender;

    personReceiver.cred = patientAbhaId; //Receiver hpr/abha id
    personReceiver.name = patientName;
    personReceiver.gender = patientGender;
    personReceiver.image = "image";
    receiver.person = personReceiver;

    /*personSender.cred = _doctorHprId; //Sender hpr/abha id
    sender.person = personSender;

    personReceiver.cred = _patientAbhaId; //Receiver hpr/abha id
    receiver.person = personReceiver;*/

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
      ChatMessageModel chatMessage = await getChatMessageObject(chatMessageModel);


      /// TODO need to get shared file details


      /*chatMessage.sender =
          chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
      chatMessage.receiver =
          chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
      chatMessage.time =
          chatMessageModel.message?.intent?.chat?.time?.timestamp;
      chatMessage.contentId =
          chatMessageModel.message?.intent?.chat?.content?.contentId;


      chatMessage.contentValue = await Utility.decryptMessage(
          message:
              chatMessageModel.message?.intent?.chat?.content?.contentValue ??
                  "", secretKey: _sharedSecretKey!);*/

      setState(() {
        _messagesList.add(chatMessage);
        sortList();
        _chatMsgTextEditingController.clear();
        isLoading = false;

        _fileName = null;
        base64EncodeFile = null;
      });
      _postChatMessageController.refresh();
    } else if (_postChatMessageController
            .chatMessageAckDetails?.message?.ack?.status ==
        "NACK") {
      setState(() {
        isLoading = false;
        _fileName = null;
        base64EncodeFile = null;
      });
      DialogHelper.showErrorDialog(description: "Message not sent 1.");
    } else if (_postChatMessageController.errorString.isNotEmpty) {
      setState(() {
        isLoading = false;
        _fileName = null;
        base64EncodeFile = null;
      });
      DialogHelper.showErrorDialog(description: "Message not sent 2.");
    } else {
      setState(() {
        isLoading = false;
        _fileName = null;
        base64EncodeFile = null;
      });
      DialogHelper.showErrorDialog(description: "Message not sent 3.");
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async{
        if(Get.previousRoute == AppRoutes.splashPage) {
          Get.offAllNamed(AppRoutes.dashboardPage);
        } else {
          Get.back();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBackgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () {
              debugPrint('Previous page route is ${Get.previousRoute}');
              if(Get.previousRoute == AppRoutes.splashPage) {
                Get.offAllNamed(AppRoutes.dashboardPage);
              } else {
                Get.back();
              }
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.black,
            ),
          ),
          title: Text(
            patientName ?? "Patient",
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
                if (_messagesList[index].sender == doctorHprId) {
                  /*return buildSenderMessage(
                      text: _messagesList[index].contentValue ?? "");*/
                  return InkWell(
                    onTap: () {
                      if(_messagesList[index].contentType != null && _messagesList[index].contentType == 'media') {
                        Get.toNamed(AppRoutes.showSelectedMediaPage, arguments: {'media' : _messagesList[index].contentUrl, 'isUpload' : false});
                      }
                    },
                    child: buildSenderMessageNew(
                        chatMessageModel: _messagesList[index]),
                  );
                } else if (_messagesList[index].receiver == doctorHprId) {
                  /*return buildReceiverMessage(
                      text: _messagesList[index].contentValue ?? "");*/
                  return InkWell(
                    onTap: () {
                      if(_messagesList[index].contentType != null && _messagesList[index].contentType == 'media') {
                        Get.toNamed(AppRoutes.showSelectedMediaPage, arguments: {'media' : _messagesList[index].contentUrl, 'isUpload' : false});
                      }
                    },
                    child: buildReceiverMessageNew(
                        chatMessageModel: _messagesList[index]),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
        if(allowSendMessage) generateBottomWidget()
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

  buildReceiverMessageNew({required ChatMessageModel chatMessageModel}) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              chatMessageModel.contentType == 'text'
                  ? Text(
                chatMessageModel.contentValue ?? '',
                style: AppTextStyle.textSemiBoldStyle(color: AppColors.senderTextColor, fontSize: 14),
              ): chatMessageModel.contentType == 'media'
                  ? buildMediaWidget(mediaUrl: (chatMessageModel.contentValue == null || chatMessageModel.contentValue!.isEmpty) ? chatMessageModel.contentUrl : chatMessageModel.contentValue)
                  : Container(),
              VerticalSpacing(size: 2,),
              Text(
                Utility.getChatDisplayDateTime(
                    startDateTime: DateTime.parse(
                        chatMessageModel.time!.split('.').first)),
                textAlign: TextAlign.end,
                style: AppTextStyle.textLightStyle(
                    color: AppColors.senderTextColor, fontSize: 10),
              ),
            ],
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

  buildSenderMessageNew({required ChatMessageModel chatMessageModel}) {
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
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chatMessageModel.contentType == 'text'
                    ? Text(
                        chatMessageModel.contentValue ?? '',
                  textAlign: TextAlign.start,
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.white, fontSize: 14),
                      )
                    : chatMessageModel.contentType == 'media'
                        ? buildMediaWidget(
                            mediaUrl: (chatMessageModel.contentValue == null ||
                                    chatMessageModel.contentValue!.isEmpty)
                                ? chatMessageModel.contentUrl
                                : chatMessageModel.contentValue)
                        : Container(),
                VerticalSpacing(size: 2,),
                Text(
                  Utility.getChatDisplayDateTime(
                      startDateTime: DateTime.parse(
                          chatMessageModel.time!.split('.').first)),
                  textAlign: TextAlign.end,
                  style: AppTextStyle.textLightStyle(
                      color: AppColors.white, fontSize: 10),
                ),
            ],
            ),
        ),
      ],
    );
  }

  buildMediaWidget({required String? mediaUrl}) {
    Uint8List? base64DecodedFile;
    if (mediaUrl != null && !mediaUrl.contains("http")) {
      base64DecodedFile = base64Decode(mediaUrl);
    }
    return Container(
      constraints: BoxConstraints(
          minHeight: 150,
          maxHeight: 250,
          minWidth: width * 0.12,
          maxWidth: width * 0.7),
      child: base64DecodedFile == null
          ? Image.network(
              mediaUrl!,
              errorBuilder: (context, obj, stackTrace) {
                return Image.asset(AssetImages.doctorPlaceholder);
              },
            )
          : Image.memory(base64DecodedFile),
    );
  }

  generateBottomWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      color: AppColors.tileColors,
      child: Column(
        children: [
          /*if(base64EncodeFile != null && base64EncodeFile!.isNotEmpty)
              Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 220,
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // color: AppColors.greyDDDDDD,
                    image: DecorationImage(
                      image: Image.memory(
                          base64Decode(base64EncodeFile!))
                          .image,
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "$_fileName",
                      style: AppTextStyle.textBoldStyle(
                          color: AppColors.black, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),*/
          Row(
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatMsgTextEditingController,
                          maxLines: 3,
                          minLines: 1,
                          maxLength: 4096,
                          decoration: const InputDecoration(
                            hintText: "Write Message",
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.only(left: 8)
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: _handleAttachmentPressed,
                          icon: const Icon(
                            Icons.attach_file,
                            color: AppColors.tileColors,
                          ),
                      ),
                    ],
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
                          if (_chatMsgTextEditingController.text.trim().isNotEmpty
                              || (base64EncodeFile != null && _fileName != null && _fileName!.isNotEmpty)) {
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
        ],
      ),
    );
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _handleImageSelection(source: ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.amountColor,
                            child: Icon(Icons.camera, color: AppColors.white,),
                          ),
                          VerticalSpacing(),
                          Text(AppStrings().camera, style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.titleTextColor),)
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _handleImageSelection(source: ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.amountColor,
                            child: Icon(Icons.folder, color: AppColors.white,),
                          ),
                          VerticalSpacing(),
                          Text(AppStrings().gallery, style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.titleTextColor),)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })
        /*SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),*/
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      ///TODO handle send file logic
      /*final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);*/
    }
  }

  void _handleImageSelection({required ImageSource source}) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: source,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      base64EncodeFile = base64Encode(bytes);
      _fileName = result.name;
      bool isUpload = await Get.toNamed(AppRoutes.showSelectedMediaPage, arguments: {'media' : base64EncodeFile, 'isUpload' : true});
      if(isUpload) {
        if (_chatMsgTextEditingController.text.trim().isNotEmpty
            || (base64EncodeFile != null && _fileName != null && _fileName!.isNotEmpty)) {
          setState(() {
            isLoading = true;
          });
          postMessageAPI();
        } else {
        }
      } else {
        setState(() {
          base64EncodeFile = null;
          _fileName = null;
        });
      }
      // await OpenFile.open(result.path);

    } else {
      Get.snackbar(AppStrings().alert, AppStrings().errorUnableSelectMedia);
    }
  }
}
