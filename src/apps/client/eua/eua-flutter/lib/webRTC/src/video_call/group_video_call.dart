/**Created by Airesh Bhat (nelliairesh@gmail.com)
 * Date : 23-09-2022
 * 
 * This screen is the video calling screen between two participants in a tele consultation
 * This implementation is done via the message/on_message communication between the two participants
 * 
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/webrtc/src/video_call/video_call_signalling.dart';

import 'package:uhi_flutter_app/widgets/src/new_confirmation_dialog.dart';

import '../../../constants/src/strings.dart';
import '../utils/create_stream.dart';

class GroupVideoCall extends StatefulWidget {
  static String tag = 'video_call';

  const GroupVideoCall({Key? key}) : super(key: key);

  @override
  GroupVideoCallState createState() => GroupVideoCallState();
}

class GroupVideoCallState extends State<GroupVideoCall> {
  late final Map initiator;
  late final Map primaryDoctor;
  late final Map secondaryDoctor;

  bool inCalling = false;
  bool waitAccept = false;
  bool isMute = false;
  bool isSpeaker = true;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remotePrimaryDoctorRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteSecondaryDoctorRenderer = RTCVideoRenderer();
  VideoCallSignalling? _primaryDoctorSignalling;
  VideoCallSignalling? _secondaryDoctorSignalling;

  StompClient? stompClient;
  MediaStream? _localStream;

  late double height, width;

  String? _patientAbhaId = "";
  String? _primaryDoctorHprId = "";
  String? _primaryDoctorName = "";
  String? _primaryDoctorGender = "";
  String? _primaryDoctorProviderUri = "";
  String? _secondaryDoctorHprId = "";
  String? _secondaryDoctorName = "";
  String? _secondaryDoctorGender = "";
  String? _secondaryDoctorProviderUri = "";

  Session? _primarySession;
  Session? _secondarySession;

  @override
  void initState() {
    super.initState();

    debugPrint("Group video call argument:${Get.arguments}");

    initiator = Get.arguments['initiator'];
    primaryDoctor = Get.arguments['primaryDoctor'];
    secondaryDoctor = Get.arguments['secondaryDoctor'];
    _primaryDoctorHprId = primaryDoctor['address'];
    _primaryDoctorName = primaryDoctor['name'];
    _primaryDoctorGender = primaryDoctor['gender'];
    _primaryDoctorProviderUri = primaryDoctor['uri'];
    _secondaryDoctorHprId = secondaryDoctor['address'];
    _secondaryDoctorName = secondaryDoctor['name'];
    _secondaryDoctorGender = secondaryDoctor['gender'];
    _secondaryDoctorProviderUri = secondaryDoctor['uri'];
    _patientAbhaId = initiator['address'];

    startVideoCall();
  }

  startVideoCall() async {
    await initRenderers();
    _connect_primary_doctor();
    _connect_secondary_doctor();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remotePrimaryDoctorRenderer.initialize();
    await _remoteSecondaryDoctorRenderer.initialize();
    _localStream = await createStream('video', false);
  }

  @override
  deactivate() async {
    super.deactivate();
    _localRenderer.dispose();
    await _remotePrimaryDoctorRenderer.dispose();
    await _remoteSecondaryDoctorRenderer.dispose();
    _primaryDoctorSignalling?.disconnect();
    _secondaryDoctorSignalling?.disconnect();
  }

  void _connect_primary_doctor() {
    _primaryDoctorSignalling ??= VideoCallSignalling(
      receiversAddress: _primaryDoctorHprId!,
      sendersAddress: _patientAbhaId!,
      receiversGender: _primaryDoctorGender!,
      receiversName: _primaryDoctorName!,
      providerUri: _primaryDoctorProviderUri!,
      chatId: '$_patientAbhaId|$_primaryDoctorHprId',
    )..connect();
    _primaryDoctorSignalling?.setStream(_localStream!);

    _primaryDoctorSignalling?.poll();
    _primaryDoctorSignalling?.onCallStateChange =
        (Session session, CallState state) async {
      switch (state) {
        case CallState.CallStateNew:
          setState(() {
            _primarySession = session;
          });
          break;
        case CallState.CallStateRinging:
          bool? accept = await _showAcceptDialog();
          if (accept!) {
            _accept(_primaryDoctorSignalling!, session);
            setState(() {
              inCalling = true;
            });
          } else {
            _reject(_primaryDoctorSignalling!, session);
          }
          break;
        case CallState.CallStateBye:
          if (waitAccept) {
            debugPrint('peer reject');
            waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remotePrimaryDoctorRenderer.srcObject = null;
            inCalling = false;
            _primarySession = null;
          });
          break;
        case CallState.CallStateInvite:
          waitAccept = true;
          break;
        case CallState.CallStateConnected:
          if (waitAccept) {
            waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            inCalling = true;
          });

          break;
      }
    };

    _primaryDoctorSignalling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _primaryDoctorSignalling?.onAddRemoteStream = ((_, stream) {
      _remotePrimaryDoctorRenderer.srcObject = stream;
      setState(() {});
    });

    _primaryDoctorSignalling?.onRemoveRemoteStream = ((_, stream) {
      _remotePrimaryDoctorRenderer.srcObject = null;
      setState(() {});
    });
  }

  void _connect_secondary_doctor() {
    _secondaryDoctorSignalling ??= VideoCallSignalling(
      receiversAddress: _secondaryDoctorHprId!,
      sendersAddress: _patientAbhaId!,
      receiversGender: _secondaryDoctorGender!,
      receiversName: _secondaryDoctorName!,
      providerUri: _secondaryDoctorProviderUri!,
      chatId: '$_patientAbhaId|$_secondaryDoctorHprId',
    )..connect();
    _secondaryDoctorSignalling?.setStream(_localStream!);

    _secondaryDoctorSignalling?.onCallStateChange =
        (Session session, CallState state) async {
      switch (state) {
        case CallState.CallStateNew:
          setState(() {
            _secondarySession = session;
          });
          break;
        case CallState.CallStateRinging:
          _accept(_secondaryDoctorSignalling!, session);
          break;
        case CallState.CallStateBye:
          if (waitAccept) {
            debugPrint('peer reject');
            waitAccept = false;
            Navigator.of(context).pop(false);
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remoteSecondaryDoctorRenderer.srcObject = null;
            _secondarySession = null;
          });
          break;
        case CallState.CallStateInvite:
          waitAccept = true;
          _showInviteDialog();
          break;
        case CallState.CallStateConnected:
          if (waitAccept) {
            waitAccept = false;
            Navigator.of(context).pop(false);
          }
          break;
      }
    };

    _secondaryDoctorSignalling?.onLocalStream = ((stream) {});

    _secondaryDoctorSignalling?.onAddRemoteStream = ((_, stream) {
      _remoteSecondaryDoctorRenderer.srcObject = stream;
      setState(() {});
    });

    _secondaryDoctorSignalling?.onRemoveRemoteStream = ((_, stream) {
      _remoteSecondaryDoctorRenderer.srcObject = null;
      setState(() {});
    });
  }

  Future<bool?> _showAcceptDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Incoming Call",
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
          content: Text(
            "Doctor wants to connect",
            style: AppTextStyle.textMediumStyle(
                fontSize: 14, color: AppColors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Reject",
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 14, color: AppColors.black),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                "Accept",
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

  Future<bool?> _showInviteDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Connecting..",
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
          content: Text(
            "Please wait while we connect your call",
            style: AppTextStyle.textMediumStyle(
                fontSize: 14, color: AppColors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
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

  _accept(VideoCallSignalling? _videoCallSignalling, Session _session) {
    _videoCallSignalling?.accept(_session.sid);
  }

  _reject(VideoCallSignalling? _videoCallSignalling, Session _session) {
    _videoCallSignalling?.reject(_session.sid);
  }

  _hangUp() {
    if (_primarySession != null) {
      _primaryDoctorSignalling?.bye(_primarySession!.sid);
    }
    if (_secondarySession != null) {
      _secondaryDoctorSignalling?.bye(_secondarySession!.sid);
    }
  }

  _switchCamera() {
    _primaryDoctorSignalling?.switchCamera();
  }

  _muteMic() {
    setState(() {
      isMute = !isMute;
    });
    // Either of the signalling variables can be passed here
    _primaryDoctorSignalling?.muteMic();
  }

  _speaker() {
    setState(() {
      isSpeaker = !isSpeaker;
    });

    _remotePrimaryDoctorRenderer.srcObject
        ?.getAudioTracks()[0]
        .enableSpeakerphone(isSpeaker);
    _remoteSecondaryDoctorRenderer.srcObject
        ?.getAudioTracks()[0]
        .enableSpeakerphone(isSpeaker);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        _hangUp();
        if (inCalling) {
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context, false);
        }
        return true;
      },
      child: Scaffold(
          appBar: inCalling
              ? null
              : AppBar(
                  backgroundColor: AppColors.white,
                  shadowColor: Colors.black.withOpacity(0.1),
                  leading: IconButton(
                    onPressed: () {
                      //Get.back();
                      Navigator.pop(context, false);
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
                    "Doctor's Waiting Room",
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.black, fontSize: 18),
                  ),
                ),
          body: inCalling
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(children: [
                      Container(
                        width: width,
                        height: height / 2,
                        decoration: const BoxDecoration(
                            // color: Colors.amber,
                            ),
                        child: RTCVideoView(
                          _remotePrimaryDoctorRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
                        ),
                      ),
                      Container(
                        width: width,
                        height: height / 2,
                        decoration: const BoxDecoration(
                            // color: Colors.redAccent
                            ),
                        child: RTCVideoView(
                          _remoteSecondaryDoctorRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
                        ),
                      )
                    ]),
                    Positioned(
                      bottom: 30,
                      child: Container(
                        width: width * 0.9,
                        height: height * 0.075,
                        padding: EdgeInsets.only(left: 15, right: 15),
                        decoration: BoxDecoration(
                          color: Color(0xFF264488),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                _muteMic();
                              },
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
                              onTap: () {
                                _hangUp();
                                NewConfirmationDialog(
                                    context: context,
                                    title: AppStrings()
                                        .consultationDoneDialogTitle,
                                    description: AppStrings()
                                        .consultationDoneDialogDescription,
                                    submitButtonText: AppStrings().yes,
                                    onCancelTap: () {
                                      Get.back();
                                    },
                                    onSubmitTap: () {
                                      Navigator.pop(context, true);
                                      Navigator.pop(context, true);
                                    }).showAlertDialog();
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
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
                              onTap: () {
                                _switchCamera();
                              },
                              child: const Icon(
                                Icons.switch_camera,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            // const Icon(
                            //   Icons.volume_up,
                            //   size: 30,
                            //   color: Colors.grey,
                            // ),
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
                          //color: Colors.green,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
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
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "You are in $_primaryDoctorName's waiting room",
                                style: AppTextStyle.textBoldStyle(
                                    color: AppColors.tileColors, fontSize: 16),
                              ),
                              Text(
                                "Please wait, $_primaryDoctorName will let you in soon.",
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
                )),
    );
  }
}
