/**Created by Airesh Bhat (nelliairesh@gmail.com)
 * Date : 23-09-2022
 * 
 * This class is responsible for handling the signalling part of the video call
 * 
 */
///

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hspa_app/constants/constants.dart';
import 'package:hspa_app/controller/src/post_chat_message_controller.dart';
import 'package:hspa_app/model/src/chat_message_dhp_model.dart';
import 'package:hspa_app/model/src/chat_message_model.dart';
import 'package:hspa_app/model/src/context_model.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/webRTC/src/utils/create_stream.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uuid/uuid.dart';

enum CallState {
  callStateNew,
  callStateRinging,
  callStateInvite,
  callStateConnected,
  callStateBye,
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
  String _selfId = '';

  final _postChatMessageController = PostChatMessageController();

  final String sendersAddress;
  final String receiversAddress;
  final String receiversName;
  final String receiversGender;
  final String providerUri;
  final String consumerUri;
  final String chatId;
  final String postMessageSendersAddress;
  final String postMessageReceiversAddress;
  final Map<String, Session> _sessions = {};

  int counter = 0;

  DoctorProfile? _profile;
  Timer? _timer;

  MediaStream? _localStream;
  final List<MediaStream> _remoteStreams = <MediaStream>[];

  Function(MediaStream stream)? onLocalStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function(Session session, MediaStream stream)? onRemoveRemoteStream;
  Function(dynamic event)? onPeersUpdate;
  Function(Session session, CallState state)? onCallStateChange;
  Function(Session session, RTCDataChannel dc, RTCDataChannelMessage data)?
      onDataChannelMessage;
  Function(Session session, RTCDataChannel dc)? onDataChannel;

  VideoCallSignalling({
    required this.sendersAddress,
    required this.receiversAddress,
    required this.receiversName,
    required this.receiversGender,
    required this.providerUri,
    required this.chatId,
    required this.consumerUri,
    required this.postMessageSendersAddress,
    required this.postMessageReceiversAddress,
  }) {
    _selfId = sendersAddress;
  }

  String get sdpSemantics =>
      WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';

  final JsonEncoder _encoder = JsonEncoder();
  final JsonDecoder _decoder = JsonDecoder();

  StompClient? stompClient;

  String? patientId;

  Future<void> connect() async {
    await getDoctorProfile();

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
          onMessage(decodedContent, chatMessageModel);
        }
      },
    );
  }

  void onMessage(messageContent, ChatMessageDhpModel chatMessage) async {
    var data = messageContent['data'];
    var onMessageSender = messageContent['sender'];
    debugPrint(
        'onMessage: ${messageContent['type']} sent by ${chatMessage.message?.intent?.chat?.sender?.person?.name}');
    if (onMessageSender == sendersAddress) {
      return;
    }
    switch (messageContent['type']) {
      case 'READY':
        // Acknowledge the READY message
        Map<String, dynamic> event = <String, dynamic>{};
        event['peers'] = [
          {
            'name': chatMessage.message?.intent?.chat?.sender?.person?.name,
            'id': chatMessage.message?.intent?.chat?.sender?.person?.cred,
          }
        ];
        onPeersUpdate?.call(event);
        _send('ACK', true);
        break;
      case 'ACK':
        {
          debugPrint(
              'Received ACK status from ${chatMessage.message?.intent?.chat?.sender?.person?.name}');
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
          var newSession = await _createSession(session,
              peerId: peerId,
              sessionId: sessionId,
              media: media,
              screenSharing: false);
          _sessions[sessionId] = newSession;
          await newSession.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));

          if (newSession.remoteCandidates.isNotEmpty) {
            newSession.remoteCandidates.forEach((candidate) async {
              await newSession.pc?.addCandidate(candidate);
            });
            newSession.remoteCandidates.clear();
          }
          onCallStateChange?.call(newSession, CallState.callStateNew);

          onCallStateChange?.call(newSession, CallState.callStateRinging);
        }
        break;
      case 'ANSWER':
        {
          var description = data['description'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          session?.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          onCallStateChange?.call(session!, CallState.callStateConnected);
        }
        counter = 0;
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
      default:
        break;
    }
  }

  void poll() async {
    Timer.periodic(Duration(seconds: 5), (timer) {
      _timer = timer;
      debugPrint(timer.tick.toString());
      _send('READY', true);
    });
  }

  void stopPoll() {
    _timer?.cancel();
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

  void invite(String peerId, String media, bool useScreen) async {
    var sessionId = _selfId + '-' + peerId;
    Session session = await _createSession(null,
        peerId: peerId,
        sessionId: sessionId,
        media: media,
        screenSharing: useScreen);
    _sessions[sessionId] = session;
    if (media == 'data') {
      _createDataChannel(session);
    }
    _createOffer(session, media);
    onCallStateChange?.call(session, CallState.callStateNew);
    onCallStateChange?.call(session, CallState.callStateInvite);
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

  Future<void> getDoctorProfile() async {
    _profile = await DoctorProfile.getSavedProfile();
  }

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
      debugPrint(e.toString());
    }
  }

  _send(event, data) {
    debugPrint('Sending $event **********');
    var request = {};
    request["type"] = event;
    request["data"] = data;
    request["sender"] = sendersAddress;
    postMessageAPI(_encoder.convert(request));
  }

  postMessageAPI(message) async {
    var _uniqueId = const Uuid().v1();
    ChatMessageDhpModel chatMessageModel = ChatMessageDhpModel();

    ContextModel contextModel = ContextModel();
    contextModel.domain = "nic2004:85111";
    contextModel.city = "std:080";
    contextModel.country = "IND";
    contextModel.action = "message";
    contextModel.coreVersion = "0.7.1";
    contextModel.messageId = _uniqueId;
    contextModel.consumerId = "https://exampleapp.io/";
    contextModel.consumerUri = consumerUri;
    contextModel.providerUrl = providerUri;
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

    content.contentValue = message;
    content.contentType = 'video_call_signalling';

    personSender.cred = postMessageSendersAddress; //Sender hpr/abha id
    personSender.name = _profile?.displayName;
    personSender.gender = _profile?.gender;
    personSender.image = 'image2';
    // personSender.image = _profile?.profilePhoto;
    sender.person = personSender;
    debugPrint('Sending post message API from $sendersAddress **********');

    personReceiver.cred = postMessageReceiversAddress; //Receiver hpr/abha id
    debugPrint('Sending post message API to $receiversAddress **********');
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

    if (_postChatMessageController
            .chatMessageAckDetails?.message?.ack?.status ==
        "ACK") {
      ChatMessageModel chatMessage =
          await getChatMessageObject(chatMessageModel);

      _postChatMessageController.refresh();
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

  Future<MediaStream> createLocalStream(String media, bool userScreen) async {
    MediaStream localStream = await createStream(media, userScreen);
    onLocalStream?.call(localStream);
    return localStream;
  }

  Future<void> setStream(MediaStream stream) async {
    _localStream = stream;
  }

  void _addDataChannel(Session session, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      onDataChannelMessage?.call(session, channel, data);
    };
    session.dc = channel;
    onDataChannel?.call(session, channel);
  }

  Future<void> _createDataChannel(Session session,
      {label = 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()
      ..maxRetransmits = 30;
    RTCDataChannel channel =
        await session.pc!.createDataChannel(label, dataChannelDict);
    _addDataChannel(session, channel);
  }

  Future<void> _createOffer(Session session, String media) async {
    try {
      RTCSessionDescription s =
          await session.pc!.createOffer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(s);
      _send('OFFER', {
        'to': session.pid,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
        'media': media,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Session> _createSession(Session? session,
      {required String peerId,
      required String sessionId,
      required String media,
      required bool screenSharing}) async {
    var newSession = session ?? Session(sid: sessionId, pid: peerId);
    onLocalStream?.call(_localStream!);
    debugPrint('$_iceServers');
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
              _remoteStreams.add(event.streams[0]);
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
      if (counter < 10) {
        counter = counter + 1;
        await Future.delayed(const Duration(seconds: 1), () {
          _send('CANDIDATE', {
            'to': peerId,
            'from': _selfId,
            'candidate': {
              'sdpMLineIndex': candidate.sdpMLineIndex,
              'sdpMid': candidate.sdpMid,
              'candidate': candidate.candidate,
            },
            'session_id': sessionId,
          });
        });
      }
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

  Future<void> _closeSession(Session session) async {
    _localStream?.getTracks().forEach((element) async {
      await element.stop();
    });
    await _localStream?.dispose();
    _localStream = null;

    await session.pc?.close();
    await session.dc?.close();
  }
}
