import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/chat/src/get_chat_messages_controller.dart';
import 'package:uhi_flutter_app/controller/chat/src/post_chat_message_controller.dart';
import 'package:uhi_flutter_app/model/common/src/chat_message_dhp_model.dart';
import 'package:uhi_flutter_app/model/common/src/chat_message_model.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/model/response/response.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../../../common/src/get_pages.dart';
import '../../../constants/src/request_urls.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/controller.dart';

class ChatPage extends StatefulWidget {
  // String? doctorHprId;
  // String? patientAbhaId;
  // String? doctorName;
  // String? doctorGender;
  // String? providerUri;

  // ChatPage({
  //   key,
  //   this.doctorHprId,
  //   this.patientAbhaId,
  //   this.doctorName,
  //   this.doctorGender,
  //   this.providerUri,
  // }) : super(key: key);

  const ChatPage({
    key,
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
  final _getSharedKeyController = Get.put(GetSharedKeyController());
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
  bool _allowSendMessage = true;
  String? transactionID = "";

  // List<ChatMessageDhpModel> _messagesList = List.empty(growable: true);
  List<ChatMessageModel> _messagesList = List.empty(growable: true);
  Future<List<ChatMessageModel>?>? futureListOfMessages;
  bool isLoading = false;
  Timer? _timer;
  GetSharedKeyResponseModel? _getSharedKeyResponse;

  ///Encryption
  SecretKey? _sharedSecretKey;
  SecretBox? _secretBox;
  String? _privateKey;

  // Generate a key pair.
  final encryptionAlgorithm = X25519();

  ///FILE SHARING
  String? _fileName;
  String? base64EncodeFile;
  String? selectedBase64EncodeFile;

  ///Encryption algorithm
  final algorithm = AesCtr.with256bits(macAlgorithm: Hmac.sha256());

  @override
  void initState() {
    super.initState();
    // _loadMessages();

    SharedPreferencesHelper.getPrivateKey().then((value) => setState(() {
          setState(() {
            _privateKey = value;
          });
        }));

    _doctorHprId = Get.arguments['doctorHprId'];
    _patientAbhaId = Get.arguments['patientAbhaId'];
    _doctorName = Get.arguments['doctorName'];
    _doctorGender = Get.arguments['doctorGender'];
    _providerUri = Get.arguments['providerUri'];
    _allowSendMessage = Get.arguments['allowSendMessage'] ?? true;
    transactionID = Get.arguments['transactionId'];

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

  String getChatDisplayDateTime({required DateTime startDateTime}) {
    DateTime now = DateTime.now();
    DateTime justNow = DateTime.now().subtract(const Duration(minutes: 1));
    DateTime localDateTime = startDateTime.toLocal();
    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }

    String roughTimeString = DateFormat('jm').format(startDateTime);
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(const Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == yesterday.month &&
        localDateTime.year == yesterday.year) {
      return 'Yesterday, ' + roughTimeString;
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);
      return '$weekday, $roughTimeString';
    }

    return '${DateFormat('MMM dd yyyy').format(startDateTime)}, $roughTimeString';
  }

  ///CHAT MESSAGE HISTORY API
  Future<List<ChatMessageModel>?> getChatMessages() async {
    List<ChatMessageModel>? listOfMsgs = List.empty(growable: true);

    await _getSharedKeyController.getSharedKeyDetails(
        doctorId: _doctorHprId, patientId: _patientAbhaId);

    if (_getSharedKeyController.sharedKeyDetails == null ||
        _getSharedKeyController.sharedKeyDetails.isEmpty) {
    } else {
      _getSharedKeyResponse = GetSharedKeyResponseModel.fromJson(
          _getSharedKeyController.sharedKeyDetails[0]);

      if (_getSharedKeyResponse?.publicKey != null &&
          _getSharedKeyResponse?.publicKey != "") {
        List<int> publicKeyBytes =
            (jsonDecode(_getSharedKeyResponse!.publicKey!) as List)
                .map((e) => int.parse(e.toString()))
                .toList();

        List<int> privateKeyBytes = (jsonDecode(_privateKey!) as List)
            .map((e) => int.parse(e.toString()))
            .toList();

        log("$privateKeyBytes", name: "PRIVATE KEY");
        // _sharedSecretKey = SecretKey(bytes);

        // final keyPair = await encryptionAlgorithm.newKeyPair();
        final doctorPublicKey =
            SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519);

        final keyPair = SimpleKeyPairData(privateKeyBytes,
            publicKey: doctorPublicKey, type: KeyPairType.x25519);

        _sharedSecretKey = await encryptionAlgorithm.sharedSecretKey(
            keyPair: keyPair, remotePublicKey: doctorPublicKey);

        log("${await _sharedSecretKey?.extractBytes()}", name: "SECRET KEY");
      }

      await _getChatMessageController.getChatMessages(
          sender: _patientAbhaId, receiver: _doctorHprId);

      if (_getChatMessageController.chatMessages != null &&
          _getChatMessageController.chatMessages!.isNotEmpty) {
        List<ChatMessageModel> tmpList = List.empty(growable: true);
        try {
          _getChatMessageController.chatMessages?.forEach((element) async {
            ChatMessageModel chatMessageModel = ChatMessageModel();
            if (element.contentType != null && element.contentType == 'text') {
              String? message;
              if (element.contentValue != null &&
                  element.contentValue!.contains('cipher_text')) {
                message = await _decryptMessage(
                  message: element.contentValue!,
                );
              } else {
                message = element.contentValue ?? '';
              }
              chatMessageModel.contentValue = message;
            }
            if (element.contentType != null && element.contentType == 'media') {
              chatMessageModel.contentValue = '';
              chatMessageModel.contentUrl = element.contentUrl;
            }

            // String? message;
            // bool isJson = checkIfJson(element.contentValue ?? "");

            // if (isJson) {
            //   message = await _decryptMessage(message: element.contentValue!);
            // } else {
            //   message = element.contentValue;
            // }

            chatMessageModel.sender = element.sender;
            chatMessageModel.receiver = element.receiver;
            chatMessageModel.consumerUrl = element.consumerUrl;
            chatMessageModel.providerUrl = element.providerUrl;
            chatMessageModel.time = element.time;
            chatMessageModel.contentId = element.contentId;
            chatMessageModel.contentType = element.contentType;
            // chatMessageModel.contentValue = message;

            log("${jsonEncode(chatMessageModel)}", name: "LIST");

            tmpList.add(chatMessageModel);
          });
        } catch (e) {
          DialogHelper.showErrorDialog(
              description:
                  "Unable to decrypt messages.\nSomething went wrong.");
        }
        log("${jsonEncode(tmpList)}", name: "LIST");
        await Future.delayed(Duration(milliseconds: 800));
        listOfMsgs.addAll(tmpList);
        await connectToStomp();
      }
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
    //_chatId = transactionID!;

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
      callback: (frame) async {
        if (frame.body != null) {
          log("${frame.body}", name: "FRAME BODY");
          ChatMessageDhpModel chatMessageModel =
              ChatMessageDhpModel.fromJson(json.decode(frame.body!));
          //ChatMessageModel chatMessage = ChatMessageModel();
          ChatMessageModel chatMessage =
              await getChatMessageObject(chatMessageModel);
          // chatMessage.sender =
          //     chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
          // chatMessage.receiver =
          //     chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
          // chatMessage.time =
          //     chatMessageModel.message?.intent?.chat?.time?.timestamp;
          // chatMessage.contentId =
          //     chatMessageModel.message?.intent?.chat?.content?.contentId;

          // bool isJson = checkIfJson(
          //     chatMessageModel.message?.intent?.chat?.content?.contentValue ??
          //         "");

          // if (isJson) {
          //   chatMessage.contentValue = await _decryptMessage(
          //       message: chatMessageModel
          //               .message?.intent?.chat?.content?.contentValue ??
          //           "");
          // } else {
          //   chatMessage.contentValue =
          //       chatMessageModel.message?.intent?.chat?.content?.contentValue;
          // }

          _messagesList.add(chatMessage);
          _messagesList.sort((b, a) =>
              DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));
          _scrollToBottom();

          setState(() {});
        }
      },
    );
  }

  bool checkIfJson(String message) {
    try {
      jsonDecode(message);
      return true;
    } on FormatException catch (e) {
      return false;
    }
  }

  Future<ChatMessageModel> getChatMessageObject(
      ChatMessageDhpModel chatMessageModel) async {
    ChatMessageModel chatMessage = ChatMessageModel();
    chatMessage.sender =
        chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
    chatMessage.receiver =
        chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
    chatMessage.time = chatMessageModel.message?.intent?.chat?.time?.timestamp;
    chatMessage.contentId =
        chatMessageModel.message?.intent?.chat?.content?.contentId;
    chatMessage.contentType =
        chatMessageModel.message?.intent?.chat?.content?.contentType;
    if (chatMessage.contentType != null && chatMessage.contentType == 'text') {
      String? contentValue =
          chatMessageModel.message?.intent?.chat?.content?.contentValue;
      if (contentValue != null && contentValue.contains('cipher_text')) {
        try {
          chatMessage.contentValue = await _decryptMessage(
            message:
                chatMessageModel.message?.intent?.chat?.content?.contentValue ??
                    "",
          );
        } catch (e) {
          DialogHelper.showErrorDialog(
              description:
                  "Unable to decrypt messages.\nSomething went wrong.");
        }
      } else {
        chatMessage.contentValue = contentValue;
      }
    }
    if (chatMessage.contentType != null && chatMessage.contentType == 'media') {
      String? contentValue =
          chatMessageModel.message?.intent?.chat?.content?.contentValue;
      chatMessage.contentValue = '';
      if (contentValue != null && contentValue.isNotEmpty) {
        chatMessage.contentUrl =
            chatMessageModel.message?.intent?.chat?.content?.contentValue;
      } else {
        chatMessage.contentUrl =
            chatMessageModel.message?.intent?.chat?.content?.contentUrl;
      }
    }
    return chatMessage;
  }

  ///CHAT MESSAGE API
  postMessageAPI() async {
    _uniqueId = Uuid().v1();
    _postChatMessageController.refresh();
    var userData;
    String? encryptedMessage;
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
    //contextModel.transactionId = transactionID;

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
      try {
        encryptedMessage = await _encryptMessage(
          message: _chatMsgTextEditingController.text.isNotEmpty
              ? _chatMsgTextEditingController.text.trim()
              : "",
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        DialogHelper.showErrorDialog(
            description: "Something went wrong.\nMessage not sent.");
        return;
      }

      ///Encrypted message
      content.contentValue = "$encryptedMessage";
      content.contentType = 'text';
    }

    // String? encryptedMessage = await _encryptMessage(
    //     message: _chatMsgTextEditingController.text.isNotEmpty
    //         ? _chatMsgTextEditingController.text.trim()
    //         : "");

    // ///Encrypted message
    // content.contentValue = "$encryptedMessage";
    // // content.contentValue = _chatMsgTextEditingController.text.isNotEmpty
    // //     ? _chatMsgTextEditingController.text.trim()
    // //     : "";

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
      ChatMessageModel chatMessage =
          await getChatMessageObject(chatMessageModel);
      //ChatMessageModel chatMessage = ChatMessageModel();

      // chatMessage.sender =
      //     chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
      // chatMessage.receiver =
      //     chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
      // chatMessage.time =
      //     chatMessageModel.message?.intent?.chat?.time?.timestamp;
      // chatMessage.contentId =
      //     chatMessageModel.message?.intent?.chat?.content?.contentId;

      // bool isJson = checkIfJson(
      //     chatMessageModel.message?.intent?.chat?.content?.contentValue ?? "");

      // if (isJson) {
      //   chatMessage.contentValue = await _decryptMessage(
      //       message:
      //           chatMessageModel.message?.intent?.chat?.content?.contentValue ??
      //               "");
      // } else {
      //   chatMessage.contentValue =
      //       chatMessageModel.message?.intent?.chat?.content?.contentValue;
      // }

      _messagesList.add(chatMessage);
      _messagesList.sort(
          (b, a) => DateTime.parse(a.time!).compareTo(DateTime.parse(b.time!)));
      _chatMsgTextEditingController.clear();
      _scrollToBottom();

      setState(() {
        selectedBase64EncodeFile = base64EncodeFile;
        _fileName = null;
        base64EncodeFile = null;
        isLoading = false;
      });
    } else if (_postChatMessageController
            .chatMessageAckDetails?.message?.ack?.status ==
        "NACK") {
      setState(() {
        isLoading = false;
        _fileName = null;
        base64EncodeFile = null;
      });
      DialogHelper.showErrorDialog(description: "Message not sent.");
    } else if (_postChatMessageController.errorString.isNotEmpty) {
      setState(() {
        isLoading = false;
        _fileName = null;
        base64EncodeFile = null;
      });
      DialogHelper.showErrorDialog(description: "Message not sent.");
    } else {
      setState(() {
        isLoading = false;
        _fileName = null;
        base64EncodeFile = null;
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

  Future<String?> _encryptMessage({required String message}) async {
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

    return "${jsonEncode(chatMessageEncryptionModel)}";
  }

  Future<String?> _decryptMessage({required String message}) async {
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
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        debugPrint('onWillPop Previous route is ${Get.previousRoute}');
        if (Get.previousRoute == AppRoutes.splashPage) {
          Get.offAllNamed(AppRoutes.homePage);
        } else {
          Get.back();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              debugPrint('Previous route is ${Get.previousRoute}');
              if (Get.previousRoute == AppRoutes.splashPage) {
                Get.offAllNamed(AppRoutes.homePage);
              } else {
                Get.back();
              }
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
      ),
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
                // if (_messagesList[index].sender == _patientAbhaId) {
                //   return buildSenderMessage(
                //       text: _messagesList[index].contentValue ?? "");
                // } else if (_messagesList[index].receiver == _patientAbhaId) {
                //   return buildReceiverMessage(
                //       text: _messagesList[index].contentValue ?? "");
                // } else {
                //   return Container();
                // }
                if (_messagesList[index].sender == _patientAbhaId) {
                  return buildSenderMessageNew(
                      chatMessageModel: _messagesList[index]);
                } else if (_messagesList[index].receiver == _patientAbhaId) {
                  return buildReceiverMessageNew(
                      chatMessageModel: _messagesList[index]);
                } else {
                  return Container();
                }
              },
            ),
          ),
          _allowSendMessage ? generateBottomWidget() : Container(),
        ],
      ),
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
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: const Color(0xFF264488),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                    //bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chatMessageModel.contentType == 'text'
                    ? Text(
                        chatMessageModel.contentValue ?? '',
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.white, fontSize: 15),
                      )
                    : chatMessageModel.contentType == 'media'
                        ? GestureDetector(
                            onTap: () {
                              String? mediaUrl =
                                  (chatMessageModel.contentValue == null ||
                                          chatMessageModel
                                              .contentValue!.isEmpty)
                                      ? chatMessageModel.contentUrl
                                      : chatMessageModel.contentValue;
                              print("Receiver Image clicked");
                              Get.toNamed(AppRoutes.showSelectedMediaPage,
                                  arguments: {
                                    'media': '',
                                    'mediaUrl': mediaUrl,
                                    'isUpload': false
                                  });
                            },
                            child: buildMediaWidget(
                                mediaUrl: (chatMessageModel.contentValue ==
                                            null ||
                                        chatMessageModel.contentValue!.isEmpty)
                                    ? chatMessageModel.contentUrl
                                    : chatMessageModel.contentValue))
                        : Container(),
                SizedBox(
                  height: 2,
                ),
                Text(
                  getChatDisplayDateTime(
                      startDateTime: DateTime.parse(
                          chatMessageModel.time!.split('.').first)),
                  textAlign: TextAlign.end,
                  style: AppTextStyle.textLightStyle(
                      color: AppColors.white, fontSize: 10),
                ),
              ],
            )),
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
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: const Color(0xFFE9ECF3),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chatMessageModel.contentType == 'text'
                    ? Text(
                        chatMessageModel.contentValue ?? '',
                        style: AppTextStyle.textSemiBoldStyle(
                            color: Color(0xFF264488), fontSize: 15),
                      )
                    : chatMessageModel.contentType == 'media'
                        ? GestureDetector(
                            onTap: () {
                              String? mediaUrl =
                                  (chatMessageModel.contentValue == null ||
                                          chatMessageModel
                                              .contentValue!.isEmpty)
                                      ? chatMessageModel.contentUrl
                                      : chatMessageModel.contentValue;
                              Get.toNamed(AppRoutes.showSelectedMediaPage,
                                  arguments: {
                                    'media': selectedBase64EncodeFile,
                                    'mediaUrl': mediaUrl,
                                    'isUpload': false
                                  });
                            },
                            child: buildMediaWidget(
                                mediaUrl: (chatMessageModel.contentValue ==
                                            null ||
                                        chatMessageModel.contentValue!.isEmpty)
                                    ? chatMessageModel.contentUrl
                                    : chatMessageModel.contentValue),
                          )
                        : Container(),
                SizedBox(
                  height: 2,
                ),
                Text(
                  getChatDisplayDateTime(
                      startDateTime: DateTime.parse(
                          chatMessageModel.time!.split('.').first)),
                  textAlign: TextAlign.end,
                  style: AppTextStyle.textLightStyle(
                      color: Color(0xFF264488), fontSize: 10),
                ),
              ],
            )),
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
                return Image.asset('assets/images/dummy_image.jpeg');
              },
            )
          : Image.memory(base64DecodedFile),
    );
  }

  generateBottomWidget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
      color: AppColors.tileColors,
      child:
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Expanded(
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: AppColors.white,
          //           borderRadius: BorderRadius.circular(10),
          //           boxShadow: const [
          //             BoxShadow(
          //               offset: Offset(0, 10),
          //               blurRadius: 20,
          //               color: Color(0x1B1C204D),
          //             )
          //           ],
          //         ),
          //         child: TextField(
          //           controller: _chatMsgTextEditingController,
          //           maxLines: 3,
          //           minLines: 1,
          //           decoration: const InputDecoration(
          //               hintText: "Write Message",
          //               border: InputBorder.none,
          //               contentPadding: EdgeInsets.only(left: 8, right: 8)),
          //         ),
          //       ),
          //     ),
          //     Center(
          //       child: isLoading
          //           ? Container(
          //               padding: const EdgeInsets.all(8),
          //               width: 48,
          //               height: 48,
          //               child: CircularProgressIndicator(
          //                 color: AppColors.white,
          //               ),
          //             )
          //           : IconButton(
          //               onPressed: () {
          //                 if (_chatMsgTextEditingController.text
          //                     .trim()
          //                     .isNotEmpty) {
          //                   setState(() {
          //                     isLoading = true;
          //                   });
          //                   postMessageAPI();
          //                 }
          //               },
          //               icon: Icon(
          //                 Icons.send,
          //                 color: AppColors.white,
          //                 size: 32,
          //               ),
          //             ),
          //     ),
          //   ],
          // ),
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
                        hintText: "Write a message",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 8),
                        counterText: '',
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
                      if (_chatMsgTextEditingController.text
                              .trim()
                              .isNotEmpty ||
                          (base64EncodeFile != null &&
                              _fileName != null &&
                              _fileName!.isNotEmpty)) {
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

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(child: StatefulBuilder(
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
                      child: Icon(
                        Icons.camera,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppStrings().camera,
                      style: AppTextStyle.textMediumStyle(
                          fontSize: 16, color: AppColors.titleTextColor),
                    )
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
                      child: Icon(
                        Icons.folder,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppStrings().gallery,
                      style: AppTextStyle.textMediumStyle(
                          fontSize: 16, color: AppColors.titleTextColor),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      })),
    );
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
      bool isUpload = await Get.toNamed(AppRoutes.showSelectedMediaPage,
          arguments: {
            'media': base64EncodeFile,
            'mediaUrl': '',
            'isUpload': true
          });
      if (isUpload) {
        if (_chatMsgTextEditingController.text.trim().isNotEmpty ||
            (base64EncodeFile != null &&
                _fileName != null &&
                _fileName!.isNotEmpty)) {
          setState(() {
            isLoading = true;
          });
          postMessageAPI();
        } else {}
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
}
