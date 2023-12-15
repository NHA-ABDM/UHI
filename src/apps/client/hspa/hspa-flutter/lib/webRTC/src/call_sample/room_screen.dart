
import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  ///SCREEN WIDTH
  var width;

  ///SCREEN HEIGHT
  var height;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
                // color: Colors.amber,
                ),
            // child: RTCVideoView(
            //   _remoteRenderer,
            //   mirror: true,
            //   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            // ),
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
                  const Icon(
                    Icons.chat,
                    size: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Icon(
                    Icons.mic,
                    size: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
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
                  const Icon(
                    Icons.videocam,
                    size: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  const Icon(
                    Icons.volume_up,
                    size: 30,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 120,
            child: Container(
              width: width * 0.3,
              height: height * 0.2,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              // child: RTCVideoView(
              //   _localRenderer,
              //   mirror: true,
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
