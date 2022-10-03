/**Created by Airesh Bhat (nelliairesh@gmail.com)
 * Date : 23-09-2022
 * 
 * This screen is the video calling screen between two participants in a tele consultation
 * This implementation is done via the message/on_message communication between the two participants
 * 
 */

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:uhi_flutter_app/constants/constants.dart';
import 'package:uhi_flutter_app/controller/chat/chat.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/webrtc/src/video_call/video_call_signalling.dart';

import 'package:uhi_flutter_app/widgets/src/new_confirmation_dialog.dart';

import '../../../constants/src/strings.dart';
import '../utils/create_stream.dart';

class VideoCall extends StatefulWidget {
  static String tag = 'video_call';

  const VideoCall({Key? key}) : super(key: key);

  @override
  VideoCallState createState() => VideoCallState();
}

class VideoCallState extends State<VideoCall> {
  late final Map initiator;
  late final Map remoteParticipant;

  bool inCalling = false;
  bool waitAccept = false;
  bool isMute = false;
  bool isSpeaker = true;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  VideoCallSignalling? _videoCallSignalling;

  StompClient? stompClient;
  MediaStream? _localStream;

  late double height, width;

  String? _providerUri = "";
  String? _doctorHprId = "";
  String? _patientAbhaId = "";
  String? _doctorName = "";
  String? _doctorGender = "";

  Session? _session;

  @override
  void initState() {
    super.initState();

    initiator = Get.arguments['initiator'];
    remoteParticipant = Get.arguments['remoteParticipant'];
    _doctorHprId = remoteParticipant['address'];
    _patientAbhaId = initiator['address'];
    _doctorName = remoteParticipant['name'];
    _doctorGender = remoteParticipant['gender'];
    _providerUri = remoteParticipant['uri'];
    //_providerUri = "http://hspasbx.abdm.gov.in";

    startVideoCall();
  }

  startVideoCall() async {
    await initRenderers();
    _connect();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _localStream = await createStream('video', false);
  }

  @override
  deactivate() async {
    super.deactivate();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _videoCallSignalling?.disconnect();
  }

  void _connect() {
    _videoCallSignalling ??= VideoCallSignalling(
      receiversAddress: _doctorHprId!,
      sendersAddress: _patientAbhaId!,
      receiversGender: _doctorGender!,
      receiversName: _doctorName!,
      providerUri: _providerUri!,
      chatId: '$_patientAbhaId|$_doctorHprId',
    )..connect();
    _videoCallSignalling?.setStream(_localStream!);

    _videoCallSignalling?.poll();
    _videoCallSignalling?.onCallStateChange =
        (Session session, CallState state) async {
      switch (state) {
        case CallState.CallStateNew:
          setState(() {
            _session = session;
          });
          break;
        case CallState.CallStateRinging:
          bool? accept = await _showAcceptDialog();
          if (accept!) {
            _accept();
            setState(() {
              inCalling = true;
            });
          } else {
            _reject();
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
            _remoteRenderer.srcObject = null;
            inCalling = false;
            _session = null;
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
          setState(() {
            inCalling = true;
          });

          break;
      }
    };

    _videoCallSignalling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _videoCallSignalling?.onAddRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    _videoCallSignalling?.onRemoveRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = null;
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

  _accept() {
    if (_session != null) {
      _videoCallSignalling?.accept(_session!.sid);
    }
  }

  _reject() {
    if (_session != null) {
      _videoCallSignalling?.reject(_session!.sid);
    }
  }

  _hangUp() {
    if (_session != null) {
      _videoCallSignalling?.bye(_session!.sid);
    }
  }

  _switchCamera() {
    _videoCallSignalling?.switchCamera();
  }

  _muteMic() {
    setState(() {
      isMute = !isMute;
    });
    _videoCallSignalling?.muteMic();
  }

  _speaker() {
    setState(() {
      isSpeaker = !isSpeaker;
    });

    _remoteRenderer.srcObject
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
                    Container(
                      width: width,
                      height: height,
                      decoration: const BoxDecoration(
                          // color: Colors.amber,
                          ),
                      child: RTCVideoView(
                        _remoteRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      ),
                    ),
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "You are in $_doctorName's waiting room",
                                  style: AppTextStyle.textBoldStyle(
                                      color: AppColors.tileColors,
                                      fontSize: 16),
                                ),
                              ),
                              Text(
                                "Please wait, $_doctorName will let you in soon.",
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
