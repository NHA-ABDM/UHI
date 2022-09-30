/**Created by Airesh Bhat (nelliairesh@gmail.com)
 * Date : 30-09-2022
 * 
 * This screen is the video calling screen between three participants in a tele consultation
 * This implementation is done via the message/on_message communication
 * This screen is specific to the secondary doctor
 * 
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/constants.dart';
import 'package:hspa_app/controller/src/get_shared_key_controller.dart';
import 'package:hspa_app/controller/src/post_chat_message_controller.dart';
import 'package:hspa_app/webRTC/src/utils/create_stream.dart';
import 'video_call_signalling.dart';
import 'package:stomp_dart_client/stomp.dart';

import 'package:hspa_app/constants/src/strings.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/theme/theme.dart';
import 'package:wakelock/wakelock.dart';

class GroupVideoCallSecondary extends StatefulWidget {
  static String tag = 'video_call';

  const GroupVideoCallSecondary({Key? key}) : super(key: key);

  @override
  GroupVideoCallSecondaryState createState() => GroupVideoCallSecondaryState();
}

class GroupVideoCallSecondaryState extends State<GroupVideoCallSecondary> {
  // Arguments
  late final Map initiator;
  late final Map remotePatient;
  late final Map remoteDoctor;

  List<dynamic> _peers = [];
  dynamic _patientPeer = null;
  dynamic _doctorPeer = null;

  bool _inCalling = false;
  bool _waitAccept = false;
  bool isMute = false;
  bool isSpeaker = true;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remotePatientRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteDoctorRenderer = RTCVideoRenderer();

  String? doctorHprId = "";
  String? remotePatientAbhaId = "";
  String? remotePatientGender = "";
  String? remotePatientName = "";
  String? remotePatientUri = "";
  String? remoteDoctorHprId = "";
  String? remoteDoctorGender = "";
  String? remoteDoctorName = "";
  String? remoteDoctorUri = "";
  String? roomId;

  Session? _patientSession;
  Session? _doctorSession;
  MediaStream? _localStream;

  VideoCallSignalling? _patientVideoCallSignalling;
  VideoCallSignalling? _doctorVideoCallSignalling;

  late double height, width;

  @override
  void initState() {
    super.initState();
    // Get arguments
    initiator = Get.arguments['initiator'];
    remotePatient = Get.arguments['remotePatient'];
    remoteDoctor = Get.arguments['remoteDoctor'];
    doctorHprId = initiator['address'];
    remotePatientAbhaId = remotePatient['address'];
    remotePatientGender = remotePatient['gender'];
    remotePatientName = remotePatient['name'];
    remotePatientUri = remotePatient['uri'];
    remoteDoctorHprId = remoteDoctor['address'];
    remoteDoctorGender = remoteDoctor['gender'];
    remoteDoctorName = remoteDoctor['name'];
    remoteDoctorUri = remoteDoctor['uri'];

    Wakelock.enable();

    startVideoCall();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remotePatientRenderer.initialize();
    await _remoteDoctorRenderer.initialize();
    _localStream = await createStream('video', false);
  }

  startVideoCall() async {
    await initRenderers();
    _connectPatient();
    _connectDoctor();
  }

  @override
  deactivate() async {
    Wakelock.disable();
    super.deactivate();
    _localRenderer.dispose();
    await _remotePatientRenderer.dispose();
    await _remoteDoctorRenderer.dispose();
    _doctorVideoCallSignalling?.disconnect();
    _patientVideoCallSignalling?.disconnect();
  }

  void _connectDoctor() {
    _doctorVideoCallSignalling ??= VideoCallSignalling(
        postMessageSendersAddress: doctorHprId!,
        postMessageReceiversAddress: remoteDoctorHprId!,
        sendersAddress: doctorHprId!,
        receiversAddress: remoteDoctorHprId!,
        receiversGender: remoteDoctorGender!,
        receiversName: remoteDoctorName!,
        providerUri: remoteDoctorUri!,
        consumerUri: 'http://100.96.9.171:8084/api/v1',
        chatId: '$doctorHprId|$remoteDoctorHprId')
      ..connect();
    _doctorVideoCallSignalling?.setStream(_localStream!);

    _doctorVideoCallSignalling?.poll();
    _doctorVideoCallSignalling?.onCallStateChange =
        (Session session, CallState state) async {
      switch (state) {
        case CallState.callStateNew:
          setState(() {
            _doctorSession = session;
          });
          break;
        case CallState.callStateRinging:
          bool? accept = await _showAcceptDialog();
          if (accept!) {
            _accept(_doctorVideoCallSignalling!, session);
            _invitePatient(false);
            setState(() {
              _inCalling = true;
            });
          } else {
            _reject();
          }
          break;
        case CallState.callStateBye:
          if (_waitAccept) {
            debugPrint('peer reject');
            _waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remoteDoctorRenderer.srcObject = null;
            _inCalling = false;
            _patientSession = null;
          });
          break;
        case CallState.callStateInvite:
          _waitAccept = true;
          break;
        case CallState.callStateConnected:
          setState(() {
            _inCalling = true;
          });

          break;
      }
    };

    _doctorVideoCallSignalling?.onPeersUpdate = ((event) {
      if (mounted) {
        setState(() {
          _doctorPeer = event['peers'];
          _peers.add(event['peers']);

          /// this will remove the user own entry and we can show proper indexing in list view
          if (event.containsKey('roomId')) {
            roomId = event['roomId'];
          }
        });
      }
    });

    _doctorVideoCallSignalling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _doctorVideoCallSignalling?.onAddRemoteStream = ((_, stream) {
      _remoteDoctorRenderer.srcObject = stream;
      setState(() {});
    });

    _doctorVideoCallSignalling?.onRemoveRemoteStream = ((_, stream) {
      _remoteDoctorRenderer.srcObject = null;
      setState(() {});
    });
  }

  void _connectPatient() {
    _patientVideoCallSignalling ??= VideoCallSignalling(
        sendersAddress: doctorHprId!,
        receiversAddress: remotePatientAbhaId!,
        postMessageSendersAddress: doctorHprId!,
        postMessageReceiversAddress: remotePatientAbhaId!,
        receiversGender: remotePatientGender!,
        receiversName: remotePatientName!,
        providerUri: remotePatientUri!,
        consumerUri: RequestUrls.consumerUri,
        chatId: '$remotePatientAbhaId|$doctorHprId')
      ..connect();
    _patientVideoCallSignalling?.setStream(_localStream!);

    _patientVideoCallSignalling?.onCallStateChange =
        (Session session, CallState state) async {
      switch (state) {
        case CallState.callStateNew:
          setState(() {
            _patientSession = session;
          });
          break;
        case CallState.callStateRinging:
          break;
        case CallState.callStateBye:
          if (_waitAccept) {
            debugPrint('peer reject');
            _waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remotePatientRenderer.srcObject = null;
            _inCalling = false;
            _patientSession = null;
          });
          break;
        case CallState.callStateInvite:
          _waitAccept = true;
          break;
        case CallState.callStateConnected:
          setState(() {
            _inCalling = true;
          });

          break;
      }
    };

    _patientVideoCallSignalling?.onPeersUpdate = ((event) {
      if (mounted) {
        setState(() {
          _patientPeer = event['peers'];
          _peers.add(event['peers']);

          /// this will remove the user own entry and we can show proper indexing in list view
          if (event.containsKey('roomId')) {
            roomId = event['roomId'];
          }
        });
      }
    });

    _patientVideoCallSignalling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    _patientVideoCallSignalling?.onAddRemoteStream = ((_, stream) {
      _remotePatientRenderer.srcObject = stream;
      setState(() {});
    });

    _patientVideoCallSignalling?.onRemoveRemoteStream = ((_, stream) {
      _remotePatientRenderer.srcObject = null;
      setState(() {});
    });
  }

  Future<bool?> _showAcceptDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppStrings().labelIncomingCall,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
          content: Text(
            'Doctor wants to connect',
            style: AppTextStyle.textMediumStyle(
                fontSize: 14, color: AppColors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppStrings().btnReject,
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 14, color: AppColors.black),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                AppStrings().btnAccept,
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 14, color: AppColors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  _accept(VideoCallSignalling? _videoCallSignalling, Session? _session) {
    if (_session != null) {
      _videoCallSignalling?.accept(_session.sid);
    }
  }

  _invitePatient(bool useScreen) async {
    if (_patientVideoCallSignalling != null) {
      _patientVideoCallSignalling?.invite(
          remotePatientAbhaId!, 'video', useScreen);
    }
  }

  _reject() {
    // if (_session != null) {
    //   _videoCallSignalling?.reject(_session!.sid);
    // }
  }

  _hangUp() {
    if (_doctorSession != null) {
      _doctorVideoCallSignalling?.bye(_doctorSession!.sid);
    }
    if (_patientSession != null) {
      _patientVideoCallSignalling?.bye(_patientSession!.sid);
    }
  }

  _switchCamera() {
    _doctorVideoCallSignalling?.switchCamera();
  }

  _muteMic() {
    setState(() {
      isMute = !isMute;
    });
    _doctorVideoCallSignalling?.muteMic();
  }

  _speaker() {
    for (MediaStreamTrack audioTrack
        in _remoteDoctorRenderer.srcObject!.getAudioTracks()) {
      debugPrint(
          'In audioTrack ${audioTrack.enabled} --> ${audioTrack.label} ---> ${audioTrack.kind} ---> ${audioTrack.muted} ---> ${audioTrack.toString()}');
    }
    _remoteDoctorRenderer.srcObject
        ?.getAudioTracks()[0]
        .enableSpeakerphone(isSpeaker);
    for (MediaStreamTrack audioTrack
        in _remotePatientRenderer.srcObject!.getAudioTracks()) {
      debugPrint(
          'In audioTrack ${audioTrack.enabled} --> ${audioTrack.label} ---> ${audioTrack.kind} ---> ${audioTrack.muted} ---> ${audioTrack.toString()}');
    }
    setState(() {
      isSpeaker = !isSpeaker;
    });
    _remotePatientRenderer.srcObject
        ?.getAudioTracks()[0]
        .enableSpeakerphone(isSpeaker);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: _inCalling
            ? null
            : AppBar(
                backgroundColor: AppColors.white,
                shadowColor: Colors.black.withOpacity(0.1),
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
                titleSpacing: 0,
                title: Text(
                  AppStrings().labelWaitingRoom,
                  style: AppTextStyle.textBoldStyle(
                      color: AppColors.black, fontSize: 18),
                ),
              ),
        body: _inCalling
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: width,
                        height: height / 2,
                        decoration: const BoxDecoration(
                            // color: Colors.amber,
                            ),
                        child: RTCVideoView(
                          _remotePatientRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
                        ),
                      ),
                      Container(
                        width: width,
                        height: height / 2,
                        decoration: const BoxDecoration(
                            // color: Colors.amber,
                            ),
                        child: RTCVideoView(
                          _remoteDoctorRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 30,
                    child: Container(
                      width: width * 0.9,
                      height: height * 0.075,
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF264488),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          InkWell(
                            onTap: _muteMic,
                            child: Icon(
                              isMute ? Icons.mic_off : Icons.mic,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          InkWell(
                            onTap: _hangUp,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: const Icon(
                                Icons.call_end_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          InkWell(
                            onTap: _switchCamera,
                            child: const Icon(
                              Icons.switch_camera,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          InkWell(
                            onTap: () {
                              _speaker();
                            },
                            child: Icon(
                              isSpeaker ? Icons.volume_up : Icons.headphones,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 120,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      width: width * 0.3,
                      height: height * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                width: width,
                height: height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "You are in $remoteDoctorName's waiting room",
                              style: AppTextStyle.textBoldStyle(
                                  color: AppColors.tileColors, fontSize: 16),
                            ),
                            Text(
                              "Please wait, $remoteDoctorName will let you in soon.",
                              style: AppTextStyle.textLightStyle(
                                  color: AppColors.lightTextColor,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _hangUp();
                        // Get.back();
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        width: width * 0.92,
                        // height: height * 0.08,
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFFE8705A),
                        ),
                        child: Center(
                          child: Text(
                            "LEAVE ROOM",
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
