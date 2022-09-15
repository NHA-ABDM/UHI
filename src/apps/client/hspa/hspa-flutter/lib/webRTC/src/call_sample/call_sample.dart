import 'dart:math';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:hspa_app/constants/src/strings.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:core';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import 'signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallSample extends StatefulWidget {
  static String tag = 'call_sample';

  const CallSample({Key? key}) : super(key: key);
/*  final String host;

  const CallSample({Key? key, required this.host}) : super(key: key);*/

  @override
  _CallSampleState createState() => _CallSampleState();
}

class _CallSampleState extends State<CallSample> {

  /// Arguments
  late final String host;

  Signaling? _signaling;
  List<dynamic> _peers = [];
  String? _selfId;
  String? roomId;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Session? _session;

  bool _waitAccept = false;
  bool isMute = false;
  bool isSpeaker = true;

  // ignore: unused_element
  _CallSampleState();

  late double height, width;

  @override
  initState() {

    /// Get Arguments
    host = Get.arguments['host'];

    Wakelock.enable();
    super.initState();
    initRenderers();
    _connect();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() async{
    Wakelock.disable();
    super.deactivate();
    _signaling?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _connect() async {
    _signaling ??= Signaling(host)..connect();
    _signaling?.onSignalingStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.connectionClosed:
        case SignalingState.connectionError:
        case SignalingState.connectionOpen:
          break;
      }
    };

    _signaling?.onCallStateChange = (Session session, CallState state) async {
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

    _signaling?.onPeersUpdate = ((event) {
      if(mounted) {
        setState(() {
          _selfId = event['self'];
          _peers = event['peers'];
          /// this will remove the user own entry and we can show proper indexing in list view
          _peers.removeWhere((element) => element['id'] == _selfId);
          if (event.containsKey('roomId')) {
            roomId = event['roomId'];
          }
        });
      }
    });

    _signaling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onAddRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onRemoveRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = null;
      setState(() {});
    });
  }


  Future<bool?> _showAcceptDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings().labelIncomingCall, style: AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),),
          content: Text(AppStrings().labelPatientWantsToConnect, style: AppTextStyle.textMediumStyle(fontSize: 14, color: AppColors.black),),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings().btnReject, style: AppTextStyle.textSemiBoldStyle(fontSize: 14, color: AppColors.black),),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(AppStrings().btnAccept, style: AppTextStyle.textSemiBoldStyle(fontSize: 14, color: AppColors.black),),
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
          title: Text(AppStrings().labelConnecting, style: AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),),
          content: Text(AppStrings().labelWaitWhileConnectCall, style: AppTextStyle.textMediumStyle(fontSize: 14, color: AppColors.black),),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings().btnCancel.camelCase!, style: AppTextStyle.textSemiBoldStyle(fontSize: 14, color: AppColors.black),),
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

  _invitePeer(BuildContext context, String peerId, bool useScreen) async {
    if (_signaling != null && peerId != _selfId) {
      _signaling?.invite(peerId, 'video', useScreen);
    }
  }

  _accept() {
    if (_session != null) {
      _signaling?.accept(_session!.sid);
    }
  }

  _reject() {
    if (_session != null) {
      _signaling?.reject(_session!.sid);
    }
  }

  _hangUp() {
    if (_session != null) {
      _signaling?.bye(_session!.sid);
    }
  }

  _switchCamera() {
    _signaling?.switchCamera();
  }

  _muteMic() {
    setState(() {
      isMute = !isMute;
    });
    _signaling?.muteMic();
  }

  _buildRow(context, peer) {
    var self = (peer['id'] == _selfId);
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(self
           /* ? peer['name'] + ', ID: ${peer['id']} ' + ' [Your self]'
            : peer['name'] + ', ID: ${peer['id']} '),*/
            ? peer['name'] + ' [Your self]'
            : peer['name']),
        onTap: null,
        trailing: SizedBox(
            width: 100.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.videocam,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () => _invitePeer(context, peer['id'], false),
                    tooltip: 'Video calling',
                  ),
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.screen_share,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () => _invitePeer(context, peer['id'], true),
                    tooltip: 'Screen sharing',
                  )
                ])),
        subtitle: Text('[' + peer['user_agent'] + ']'),
      ),
      const Divider()
    ]);
  }

  Widget buildListRow(BuildContext context, int index) {
    var self = (_peers[index]['id'] == _selfId);
    if(self)  return Container();
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
                /*? _peers[index]['name'] +
                    ', ID: ${_peers[index]['id']} ' +
                    ' [Your self]'
                : _peers[index]['name'] + ', ID: ${_peers[index]['id']} ',*/
                ? _peers[index]['name']+
                    ' [Your self]'
                : _peers[index]['name'],
            style: AppTextStyle.textSemiBoldStyle(
                fontSize: 16, color: AppColors.testColor),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /*IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.chat,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.call,
                  size: 24,
                ),
              ),*/
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

  _buildNewRow(context, peer) {
    var self = (peer['id'] == _selfId);
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(self
            /*? peer['name'] + ', ID: ${peer['id']} ' + ' [Your self]'
            : peer['name'] + ', ID: ${peer['id']} '),*/
            ? peer['name'] + ' [Your self]'
            : peer['name']),
        onTap: null,
        trailing: SizedBox(
            width: 100.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.videocam,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () => _invitePeer(context, peer['id'], false),
                    tooltip: 'Video calling',
                  ),
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.screen_share,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () => _invitePeer(context, peer['id'], true),
                    tooltip: 'Screen sharing',
                  )
                ])),
        subtitle: Text('[' + peer['user_agent'] + ']'),
      ),
      const Divider()
    ]);
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('P2P Call Sample' +
            (_selfId != null ? ' [Your ID ($_selfId)] ' : '')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: null,
            tooltip: 'setup',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
          ? SizedBox(
              width: 200.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      child: const Icon(Icons.switch_camera),
                      onPressed: _switchCamera,
                    ),
                    FloatingActionButton(
                      onPressed: _hangUp,
                      tooltip: 'Hangup',
                      child: Icon(Icons.call_end),
                      backgroundColor: Colors.pink,
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.mic_off),
                      onPressed: _muteMic,
                    )
                  ]))
          : null,
      body: _inCalling
          ? OrientationBuilder(builder: (context, orientation) {
              return Container(
                child: Stack(children: <Widget>[
                  Positioned(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: RTCVideoView(_remoteRenderer),
                        decoration: BoxDecoration(color: Colors.black54),
                      )),
                  Positioned(
                    left: 20.0,
                    top: 20.0,
                    child: Container(
                      width: orientation == Orientation.portrait ? 90.0 : 120.0,
                      height:
                          orientation == Orientation.portrait ? 120.0 : 90.0,
                      child: RTCVideoView(_localRenderer, mirror: true),
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  ),
                ]),
              );
            })
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: (_peers != null ? _peers.length : 0),
              itemBuilder: (context, i) {
                //return _buildRow(context, _peers[i]);
                return buildListRow(context, i);
              }),
    );
  }*/

  _speaker() {
      for(MediaStreamTrack audioTrack in  _remoteRenderer.srcObject!.getAudioTracks()) {
        debugPrint('In audioTrack ${audioTrack.enabled} --> ${audioTrack.label} ---> ${audioTrack.kind} ---> ${audioTrack.muted} ---> ${audioTrack.toString()}');
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
      appBar: _inCalling ? null : AppBar(
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
          style:
          AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
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
                        /*const Icon(
                          Icons.chat,
                          size: 30,
                          color: Colors.grey,
                        ),*/
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
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
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
