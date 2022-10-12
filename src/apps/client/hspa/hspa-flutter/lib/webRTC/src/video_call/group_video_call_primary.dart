/// Created by Airesh Bhat (nelliairesh@gmail.com)
/// Date : 30-09-2022
///
/// This screen is the video calling screen between three participants in a tele consultation
/// This implementation is done via the message/on_message communication
/// This screen is specific to the primary doctor
///

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

class GroupVideoCallPrimary extends StatefulWidget {
  static String tag = 'video_call';

  const GroupVideoCallPrimary({Key? key}) : super(key: key);

  @override
  GroupVideoCallPrimaryState createState() => GroupVideoCallPrimaryState();
}

class GroupVideoCallPrimaryState extends State<GroupVideoCallPrimary> {
  // Arguments
  late final Map initiator;
  late final Map remotePatient;
  late final Map remoteDoctor;

  List<dynamic> _peers = [];
  dynamic _patientPeer;
  dynamic _doctorPeer;

  bool _inCalling = false;
  bool _waitAccept = false;
  bool isMute = false;
  bool isSpeaker = true;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remotePatientRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteDoctorRenderer = RTCVideoRenderer();

  String? doctorHprId = "";
  String? doctorUri = "";
  String? remotePatientAbhaId = "";
  String? remotePatientGender = "";
  String? remotePatientName = "";
  String? remotePatientUri = "";
  String? remoteDoctorHprId = "";
  String? remoteDoctorGender = "";
  String? remoteDoctorName = "";
  String? remoteDoctorUri = "";
  String? appointmentTransactionId;
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
    appointmentTransactionId = Get.arguments['appointmentTransactionId'];
    initiator = Get.arguments['initiator'];
    remotePatient = Get.arguments['remotePatient'];
    remoteDoctor = Get.arguments['remoteDoctor'];
    doctorHprId = initiator['address'];
    doctorUri = initiator['uri'];
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

  startVideoCall() async {
    await initRenderers();
    _connectPatient();
    _connectDoctor();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remotePatientRenderer.initialize();
    await _remoteDoctorRenderer.initialize();
    _localStream = await createStream('video', false);
  }

  @override
  deactivate() async {
    Wakelock.disable();
    super.deactivate();

    _doctorVideoCallSignalling?.disconnect();
    _patientVideoCallSignalling?.disconnect();

  }

  @override
  dispose() async {
    super.dispose();
    await _localRenderer.dispose();
    await _remotePatientRenderer.dispose();
    await _remoteDoctorRenderer.dispose();
    await _localStream?.dispose();

  }

  Future<void> _connectDoctor() async {
    _doctorVideoCallSignalling ??= VideoCallSignalling(
        postMessageSendersAddress: remoteDoctorHprId!,
        postMessageReceiversAddress: doctorHprId!,
        sendersAddress: doctorHprId!,
        receiversAddress: remoteDoctorHprId!,
        receiversGender: remoteDoctorGender!,
        receiversName: remoteDoctorName!,
        providerUri: doctorUri!,
        consumerUri: remoteDoctorUri!,
        // consumerUri: 'http://100.96.9.171:8084/api/v1',
        // chatId: appointmentTransactionId ?? '$remoteDoctorHprId|$doctorHprId',
        chatId: '$remoteDoctorHprId|$doctorHprId',
    )..connect();
    await _doctorVideoCallSignalling?.setStream(_localStream!);

    _doctorVideoCallSignalling?.onCallStateChange =
        (Session session, CallState state) async {
      switch (state) {
        case CallState.callStateNew:
          setState(() {
            _doctorSession = session;
          });
          break;
        case CallState.callStateRinging:
          break;
        case CallState.callStateBye:
          debugPrint('In Group Video Call Primary Doctor CallState.callStateBye');
          if (_waitAccept) {
            debugPrint('peer reject');
            _waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remoteDoctorRenderer.srcObject = null;
            _inCalling = false;
            _doctorSession = null;
          });
          if(_patientSession != null && _patientSession?.sid != null) {
            _patientVideoCallSignalling?.bye(_patientSession!.sid);
          }

          break;
        case CallState.callStateInvite:
          _waitAccept = true;
          _showInviteDialog();
          break;
        case CallState.callStateConnected:
          if (_waitAccept) {
            _waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _inCalling = true;
          });
          break;
      }
    };

    _doctorVideoCallSignalling?.onPeersUpdate = ((event) {
      if (mounted) {
        setState(() {
          if (_doctorPeer == null) {
            _doctorPeer = event['peers'][0];
            _peers.add(event['peers'][0]);
          }

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
      for (MediaStreamTrack audioTrack
      in _remoteDoctorRenderer.srcObject!.getAudioTracks()) {
        if(audioTrack.enabled) {
          _remoteDoctorRenderer.srcObject
              ?.getAudioTracks()[_remoteDoctorRenderer.srcObject
              ?.getAudioTracks().indexOf(audioTrack) ?? 0]
              .enableSpeakerphone(true);
          break;
        }
      }
      setState(() {});
    });

    _doctorVideoCallSignalling?.onRemoveRemoteStream = ((_, stream) {
      _remoteDoctorRenderer.srcObject = null;
      setState(() {});
    });
  }

  Future<void> _connectPatient() async{
    _patientVideoCallSignalling ??= VideoCallSignalling(
        sendersAddress: doctorHprId!,
        receiversAddress: remotePatientAbhaId!,
        postMessageSendersAddress: doctorHprId!,
        postMessageReceiversAddress: remotePatientAbhaId!,
        receiversGender: remotePatientGender!,
        receiversName: remotePatientName!,
        providerUri: doctorUri!,
        // consumerUri: 'https://uhieuasandbox.abdm.gov.in/api/v1/bookingService',//remotePatientUri!,
        consumerUri: remotePatientUri!,
        // consumerUri: RequestUrls.consumerUri,
        // chatId: appointmentTransactionId ?? '$remotePatientAbhaId|$doctorHprId',
        chatId: '$remotePatientAbhaId|$doctorHprId',
    )..connect();
    await _patientVideoCallSignalling?.setStream(_localStream!);

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
          debugPrint('In Group Video Call Primary Patient CallState.callStateBye');
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
          if(_doctorSession != null && _doctorSession?.sid != null) {
            _doctorVideoCallSignalling?.bye(_doctorSession!.sid);
          }
          break;
        case CallState.callStateInvite:
          _waitAccept = true;
          break;
        case CallState.callStateConnected:
          if (_waitAccept) {
            _waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _inCalling = true;
          });

          break;
      }
    };

    _patientVideoCallSignalling?.onPeersUpdate = ((event) {
      if (mounted) {
        setState(() {
          if (_patientPeer == null) {
            _patientPeer = event['peers'][0];
            _peers.add(event['peers'][0]);
          }
        });
      }
    });

    _patientVideoCallSignalling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _patientVideoCallSignalling?.onAddRemoteStream = ((_, stream) {
      _remotePatientRenderer.srcObject = stream;
      for (MediaStreamTrack audioTrack
      in _remotePatientRenderer.srcObject!.getAudioTracks()) {
        if(audioTrack.enabled) {
          _remotePatientRenderer.srcObject
              ?.getAudioTracks()[_remotePatientRenderer.srcObject
              ?.getAudioTracks().indexOf(audioTrack) ?? 0]
              .enableSpeakerphone(true);
          break;
        }
      }
      setState(() {});
    });

    _patientVideoCallSignalling?.onRemoveRemoteStream = ((_, stream) {
      _remotePatientRenderer.srcObject = null;
      setState(() {});
    });
  }

  Future<bool?> _showInviteDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppStrings().labelConnecting,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
          content: Text(
            AppStrings().labelWaitWhileConnectCall,
            style: AppTextStyle.textMediumStyle(
                fontSize: 14, color: AppColors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppStrings().btnCancel.camelCase!,
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 14, color: AppColors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                _hangUp();
              },
            ),
          ],
        );
      },
    );
  }

  _invitePeers(bool useScreen) async {
    debugPrint('_patientVideoCallSignalling is $_patientVideoCallSignalling and patient ABHA id is $remotePatientAbhaId');
    debugPrint('_doctorVideoCallSignalling is $_doctorVideoCallSignalling');
    if (_doctorVideoCallSignalling != null) {
      await _doctorVideoCallSignalling?.invite(
          remoteDoctorHprId!, 'video', useScreen);
    }
    if (_patientVideoCallSignalling != null) {
      await _patientVideoCallSignalling?.invite(
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

  Widget buildListRow(BuildContext context, int index) {
    return Card(
      elevation: 5,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor:
                Colors.primaries[Random().nextInt(Colors.primaries.length)],
            child: Text(
              '${index + 1}',
              style: AppTextStyle.textSemiBoldStyle(
                  fontSize: 16, color: AppColors.white),
            ),
          ),
          title: Text(
            _peers[index]['name'],
            style: AppTextStyle.textSemiBoldStyle(
                fontSize: 16, color: AppColors.testColor),
          ),
        ),
      ),
    );
  }

  _speaker() {
    isSpeaker = !isSpeaker;
    for (MediaStreamTrack audioTrack
        in _remoteDoctorRenderer.srcObject!.getAudioTracks()) {
      debugPrint(
          'Group consultation primary _remoteDoctorRenderer In audioTrack ${audioTrack.enabled} --> ${audioTrack.label} ---> ${audioTrack.kind} ---> ${audioTrack.muted} ---> ${audioTrack.toString()}');

      if(audioTrack.enabled) {
        /*setState(() {
          isSpeaker = !isSpeaker;
        });*/
        _remoteDoctorRenderer.srcObject
            ?.getAudioTracks()[_remoteDoctorRenderer.srcObject
            ?.getAudioTracks().indexOf(audioTrack) ?? 0]
            .enableSpeakerphone(isSpeaker);
        break;
      }

    }
    /*_remoteDoctorRenderer.srcObject
        ?.getAudioTracks()[0]
        .enableSpeakerphone(isSpeaker);*/

    for (MediaStreamTrack audioTrack
        in _remotePatientRenderer.srcObject!.getAudioTracks()) {
      debugPrint(
          'Group consultation primary _remotePatientRenderer In audioTrack ${audioTrack.enabled} --> ${audioTrack.label} ---> ${audioTrack.kind} ---> ${audioTrack.muted} ---> ${audioTrack.toString()}');

      if(audioTrack.enabled) {
        /*setState(() {
          isSpeaker = !isSpeaker;
        });*/
        _remotePatientRenderer.srcObject
            ?.getAudioTracks()[_remotePatientRenderer.srcObject
            ?.getAudioTracks().indexOf(audioTrack) ?? 0]
            .enableSpeakerphone(isSpeaker);
        break;
      }
    }

    setState(() {});

    /*setState(() {
      isSpeaker = !isSpeaker;
    });
    _remotePatientRenderer.srcObject
          ?.getAudioTracks()[0]
        .enableSpeakerphone(isSpeaker);*/
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
                      Expanded(
                        child: Container(
                          width: width,
                          height: height / 2,
                          decoration: const BoxDecoration(
                              // color: Colors.amber,
                              ),
                          child: RTCVideoView(
                            _remotePatientRenderer,
                            mirror: true,
                            // objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: width,
                          height: height / 2,
                          decoration: const BoxDecoration(
                              // color: Colors.redAccent,
                              ),
                          child: RTCVideoView(
                            _remoteDoctorRenderer,
                            mirror: true,
                            // objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          ),
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
            : Stack(children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0.0),
                          itemCount: (_peers.length),
                          itemBuilder: (context, i) {
                            return buildListRow(context, i);
                          }),
                    ),
                    _peers.length == 2
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _invitePeers(false);
                                    },
                                    child: Text(
                                      'Start call',
                                      style: AppTextStyle.textMediumStyle(
                                          fontSize: 18, color: AppColors.black),
                                    ),
                                  ),
                                ]),
                          )
                        : Container()
                  ],
                ),
                //Expanded(child: Container()),
              ]));
  }
}
