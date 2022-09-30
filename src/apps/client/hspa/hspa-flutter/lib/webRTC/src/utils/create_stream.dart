/**Created by Airesh Bhat (nelliairesh@gmail.com)
 * Date : 30-09-2022
 * 
 * Creates a local video stream
 * 
 */

import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<MediaStream> createStream(String media, bool userScreen) async {
  final Map<String, dynamic> mediaConstraints = {
    // 'audio': userScreen ? false : true,
    'audio': true,
    'video': {
      'mandatory': {
        "width": {"min": 320, "max": 1024},
        "height": {"min": 240, "max": 768},
        'minFrameRate': '10',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };

  MediaStream stream = userScreen
      ? await navigator.mediaDevices.getDisplayMedia(mediaConstraints)
      : await navigator.mediaDevices.getUserMedia(mediaConstraints);
  return stream;
}
