/**Created by Airesh Bhat
 * Date : 30-09-2022
 * 
 * This screen is the video calling screen between two participants in a tele consultation
 * This implementation is done via the message/on_message communication between the two participants
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

class VideoCall extends StatefulWidget {
  static String tag = 'video_call';

  const VideoCall({Key? key}) : super(key: key);

  @override
  VideoCallState createState() => VideoCallState();
}

class VideoCallState extends State<VideoCall> {
  // Arguments
  late final Map initiator;
  late final Map remoteParticipant;

  List<dynamic> _peers = [];

  bool _inCalling = false;
  bool _waitAccept = false;
  bool isMute = false;
  bool isSpeaker = true;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  String? doctorHprId = "";
  String? patientAbhaId = "";
  String? patientGender = "";
  String? patientName = "";
  String? patientUri = "";
  String? _selfId = "";
  String? roomId;

  Session? _session;

  VideoCallSignalling? _videoCallSignalling;
  MediaStream? _localStream;

  late double height, width;

  @override
  void initState() {
    super.initState();
    // Get arguments
    initiator = Get.arguments['initiator'];
    remoteParticipant = Get.arguments['remoteParticipant'];
    doctorHprId = initiator['address'];
    patientAbhaId = remoteParticipant['address'];
    patientGender = remoteParticipant['gender'];
    patientName = remoteParticipant['name'];
    patientUri = remoteParticipant['uri'];
    _selfId = doctorHprId;

    Wakelock.enable();
    startVideoCall();
  }

  startVideoCall() async {
    await initRenderers();
    _connect();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    _localStream = await createStream('video', false);
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() async {
    Wakelock.disable();
    super.deactivate();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _videoCallSignalling?.disconnect();
  }

  void _connect() {
    _videoCallSignalling ??= VideoCallSignalling(
        postMessageSendersAddress: doctorHprId!,
        postMessageReceiversAddress: patientAbhaId!,
        sendersAddress: doctorHprId!,
        receiversAddress: patientAbhaId!,
        receiversGender: patientGender!,
        receiversName: patientName!,
        providerUri: patientUri!,
        consumerUri: RequestUrls.consumerUri,
        chatId: '$patientAbhaId|$doctorHprId')
      ..connect();
    _videoCallSignalling?.setStream(_localStream!);

    _videoCallSignalling?.onCallStateChange =
        (Session session, CallState state) async {
      switch (state) {
        case CallState.callStateNew:
          setState(() {
            _session = session;
          });
          break;
        case CallState.callStateRinging:
          bool? accept = await _showAcceptDialog();
          if (accept!) {
            _accept();
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
            _remoteRenderer.srcObject = null;
            _inCalling = false;
            _session = null;
          });
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

    _videoCallSignalling?.onPeersUpdate = ((event) {
      if (mounted) {
        setState(() {
          _peers = event['peers'];

          /// this will remove the user own entry and we can show proper indexing in list view
          if (event.containsKey('roomId')) {
            roomId = event['roomId'];
          }
        });
      }
    });

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
            AppStrings().labelIncomingCall,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
          content: Text(
            AppStrings().labelPatientWantsToConnect,
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

  _accept() {
    if (_session != null) {
      _videoCallSignalling?.accept(_session!.sid);
    }
  }

  _invitePeer(BuildContext context, String peerId, bool useScreen) async {
    if (_videoCallSignalling != null) {
      _videoCallSignalling?.invite(peerId, 'video', useScreen);
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

  Widget buildListRow(BuildContext context, int index) {
    var self = (_peers[index]['id'] == _selfId);
    if (self) return Container();
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
            self
                ? _peers[index]['name'] + ' [Your self]'
                : _peers[index]['name'],
            style: AppTextStyle.textSemiBoldStyle(
                fontSize: 16, color: AppColors.testColor),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  _invitePeer(context, _peers[index]['id'], false);
                },
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.video_call,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _speaker() {
    for (MediaStreamTrack audioTrack
        in _remoteRenderer.srcObject!.getAudioTracks()) {
      debugPrint(
          'In audioTrack ${audioTrack.enabled} --> ${audioTrack.label} ---> ${audioTrack.kind} ---> ${audioTrack.muted} ---> ${audioTrack.toString()}');
    }
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
                        /*const Icon(
                          Icons.volume_up,
                          size: 30,
                          color: Colors.grey,
                        ),*/
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
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: (_peers.length),
              itemBuilder: (context, i) {
                // return _buildRow(context, _peers[i]);
                return buildListRow(context, i);
              }),
    );
  }
}
