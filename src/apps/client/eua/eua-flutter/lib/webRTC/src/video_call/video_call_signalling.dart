/**Created by Airesh Bhat (nelliairesh@gmail.com)
 * Date : 23-09-2022
 * 
 * This class is responsible for handling the signalling part of the video call
 * 
 */

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as GetPackage;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/chat/chat.dart';
import 'package:uhi_flutter_app/model/common/common.dart';
import 'package:uhi_flutter_app/model/response/src/get_user_details_response.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/src/request_urls.dart';

enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
}

class Session {
  Session({required this.sid, required this.pid});
  String pid;
  String sid;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class VideoCallSignalling {
  final String receiversAddress;
  final String sendersAddress;
  final String receiversName;
  final String receiversGender;
  final String providerUri;
  final String chatId;
  final Map<String, Session> _sessions = {};

  MediaStream? _localStream;
  List<MediaStream> _remoteStreams = <MediaStream>[];

  Function(Session session, CallState state)? onCallStateChange;
  Function(MediaStream stream)? onLocalStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function(Session session, MediaStream stream)? onRemoveRemoteStream;
  Function(Session session, RTCDataChannel dc, RTCDataChannelMessage data)?
      onDataChannelMessage;
  Function(Session session, RTCDataChannel dc)? onDataChannel;

  VideoCallSignalling(
      {required this.receiversAddress,
      required this.sendersAddress,
      required this.receiversName,
      required this.receiversGender,
      required this.providerUri,
      required this.chatId}) {
    debugPrint("chatId:$chatId");
    debugPrint("providerUri:$providerUri");
  }

  final _postChatMessageController = PostChatMessageController();
  // final _postChatMessageController =
  //     GetPackage.Get.put(PostChatMessageController());

  JsonEncoder _encoder = JsonEncoder();
  JsonDecoder _decoder = JsonDecoder();
  Timer? _timer;

  StompClient? stompClient;

  String _selfId = "";
  String? patientId;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      {
        'urls': "turn:openrelay.metered.ca:80",
        'username': "openrelayproject",
        'credential': "openrelayproject",
      },
      {
        'urls': "turn:openrelay.metered.ca:443",
        'username': "openrelayproject",
        'credential': "openrelayproject",
      },
      {
        'urls': "turn:openrelay.metered.ca:443?transport=tcp",
        'username': "openrelayproject",
        'credential': "openrelayproject",
      },
    ]
  };
  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  String get sdpSemantics =>
      WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';

  Future<void> connect() async {
    stompClient = StompClient(
      config: StompConfig(
        url: RequestUrls.euaChatStompSocketUrl,
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
        onDisconnect: (dynamic data) {
          stopPoll();
          debugPrint("On Disconnect " + data.toString());
        },
        onWebSocketDone: () {
          log("Websocket closed");
          stopPoll();
        },
        stompConnectHeaders: {'chatid': chatId},
        webSocketConnectHeaders: {'chatid': chatId},
      ),
    );
    stompClient?.activate();
  }

  void disconnect() {
    stompClient?.deactivate();
    stopPoll();
  }

  Future<void> onConnect(StompFrame frame) async {
    await stompClient?.subscribe(
      destination: '/msg/queue/specific-user',
      callback: (frame) async {
        if (frame.body != null) {
          log("${frame.body}", name: "FRAME BODY");
          ChatMessageDhpModel chatMessageModel =
              ChatMessageDhpModel.fromJson(json.decode(frame.body!));
          ChatMessageModel chatMessage =
              await getChatMessageObject(chatMessageModel);
          Map<String, dynamic> decodedContent =
              _decoder.convert(chatMessage.contentValue!);
          onMessage(decodedContent);
        }
      },
    );
  }

  Future<void> setStream(MediaStream stream) async {
    _localStream = stream;
  }

  Future<Session> _createSession(Session? session,
      {required String peerId,
      required String sessionId,
      required String media,
      required bool screenSharing}) async {
    var newSession = session ?? Session(sid: sessionId, pid: peerId);
    onLocalStream?.call(_localStream!);
    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);
    if (media != 'data') {
      switch (sdpSemantics) {
        case 'plan-b':
          pc.onAddStream = (MediaStream stream) {
            onAddRemoteStream?.call(newSession, stream);
            _remoteStreams.add(stream);
          };
          await pc.addStream(_localStream!);
          break;
        case 'unified-plan':
          // Unified-Plan
          pc.onTrack = (event) {
            if (event.track.kind == 'video') {
              onAddRemoteStream?.call(newSession, event.streams[0]);
            }
          };
          _localStream!.getTracks().forEach((track) {
            pc.addTrack(track, _localStream!);
          });
          break;
      }
    }
    pc.onIceCandidate = (candidate) async {
      if (candidate == null) {
        return;
      }
      // This delay is needed to allow enough time to try an ICE candidate
      // before skipping to the next one. 1 second is just an heuristic value
      // and should be thoroughly tested in your own environment.
      await Future.delayed(
          const Duration(seconds: 1),
          () => _send('CANDIDATE', {
                'to': peerId,
                'from': _selfId,
                'candidate': {
                  'sdpMLineIndex': candidate.sdpMLineIndex,
                  'sdpMid': candidate.sdpMid,
                  'candidate': candidate.candidate,
                },
                'session_id': sessionId,
              }));
    };

    pc.onIceConnectionState = (state) {};

    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream?.call(newSession, stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(newSession, channel);
    };

    newSession.pc = pc;
    return newSession;
  }

  void _addDataChannel(Session session, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      onDataChannelMessage?.call(session, channel, data);
    };
    session.dc = channel;
    onDataChannel?.call(session, channel);
  }

  void poll() async {
    Timer.periodic(new Duration(seconds: 5), (timer) {
      _timer = timer;
      debugPrint(timer.tick.toString());
      _send('READY', true);
    });
  }

  void stopPoll() {
    _timer?.cancel();
  }

  void onMessage(message) async {
    var data = message['data'];
    switch (message['type']) {
      case 'ACK':
        {
          stopPoll();
          break;
        }
      case 'OFFER':
        {
          var peerId = data['from'];
          var description = data['description'];
          var media = data['media'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          log("session:$session");
          var newSession = await _createSession(session,
              peerId: peerId,
              sessionId: sessionId,
              media: media,
              screenSharing: false);
          _sessions[sessionId] = newSession;
          await newSession.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          //await _createAnswer(newSession, media);

          if (newSession.remoteCandidates.length > 0) {
            newSession.remoteCandidates.forEach((candidate) async {
              await newSession.pc?.addCandidate(candidate);
            });
            newSession.remoteCandidates.clear();
          }
          onCallStateChange?.call(newSession, CallState.CallStateNew);

          onCallStateChange?.call(newSession, CallState.CallStateRinging);
        }
        break;
      case 'ANSWER':
        {
          var description = data['description'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          session?.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          onCallStateChange?.call(session!, CallState.CallStateConnected);
        }
        break;
      case 'CANDIDATE':
        {
          var peerId = data['from'];
          var candidateMap = data['candidate'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          RTCIceCandidate candidate = RTCIceCandidate(candidateMap['candidate'],
              candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

          if (session != null) {
            if (session.pc != null) {
              await session.pc?.addCandidate(candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            _sessions[sessionId] = Session(pid: peerId, sid: sessionId)
              ..remoteCandidates.add(candidate);
          }
        }
        break;
      case 'BYE':
        {
          debugPrint('In Calling bye');
          var sessionId = data['session_id'];
          debugPrint('bye: ' + sessionId);
          var session = _sessions.remove(sessionId);
          if (session != null) {
            debugPrint('In session not null');
            onCallStateChange?.call(session, CallState.CallStateBye);
            _closeSession(session);
          }
          debugPrint('session is null');
        }
        break;
      default:
        break;
    }
  }

  Future<ChatMessageModel> getChatMessageObject(
      ChatMessageDhpModel chatMessageModel) async {
    ChatMessageModel chatMessage = ChatMessageModel();
    chatMessage.sender =
        chatMessageModel.message?.intent?.chat?.sender?.person?.cred;
    chatMessage.receiver =
        chatMessageModel.message?.intent?.chat?.receiver?.person?.cred;
    chatMessage.contentType =
        chatMessageModel.message?.intent?.chat?.content?.contentType;
    if (chatMessage.contentType != null &&
        chatMessage.contentType == 'video_call_signalling') {
      String? contentValue =
          chatMessageModel.message?.intent?.chat?.content?.contentValue ?? "";
      chatMessage.contentValue = contentValue;
    }
    return chatMessage;
  }

  ///CHAT MESSAGE API
  postMessageAPI(message) async {
    var _uniqueId = Uuid().v1();
    _postChatMessageController.refresh();
    var userData;
    userData = await SharedPreferencesHelper.getUserData();

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
    contextModel.providerUrl = providerUri;
    contextModel.timestamp = DateTime.now().toLocal().toUtc().toIso8601String();
    contextModel.transactionId = _uniqueId;
    //contextModel.transactionId = chatId;

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
    content.contentValue = message;
    content.contentType = 'video_call_signalling';

    personSender.cred = sendersAddress; //Sender hpr/abha id
    personSender.name = getUserDetailsResponseModel.fullName;
    personSender.gender = getUserDetailsResponseModel.gender;
    personSender.image = getUserDetailsResponseModel.profilePhoto;
    sender.person = personSender;

    personReceiver.cred = receiversAddress; //Receiver hpr/abha id
    personReceiver.name = receiversName;
    personReceiver.gender = receiversGender;
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

    await _postChatMessageController.postChatMessageDetails(
        chatMessageDetails: chatMessageModel);
  }

  void bye(String sessionId) {
    _send('BYE', {
      'session_id': sessionId,
      'from': _selfId,
    });
    var sess = _sessions[sessionId];
    if (sess != null) {
      _closeSession(sess);
    }
  }

  void accept(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    _createAnswer(session, 'video');
  }

  void reject(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    bye(session.sid);
  }

  _send(event, data) {
    var request = Map();
    request["type"] = event;
    request["data"] = data;
    postMessageAPI(_encoder.convert(request));
  }

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };
  Future<void> _createAnswer(Session session, String media) async {
    try {
      RTCSessionDescription s =
          await session.pc!.createAnswer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(s);
      _send('ANSWER', {
        'to': session.pid,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _closeSession(Session session) async {
    _localStream?.getTracks().forEach((element) async {
      await element.stop();
    });
    await _localStream?.dispose();
    _localStream = null;

    await session.pc?.close();
    await session.dc?.close();
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void muteMic() {
    if (_localStream != null) {
      debugPrint('In mute mic ${_localStream!.getAudioTracks()[0].enabled}');
      _localStream!.getAudioTracks()[0].enabled =
          !_localStream!.getAudioTracks()[0].enabled;
      debugPrint(
          'In mute mic after click ${_localStream!.getAudioTracks()[0].enabled}');
    }
  }
}
