import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';

class ShowSelectedMediaPage extends StatefulWidget {
  const ShowSelectedMediaPage({Key? key}) : super(key: key);

  @override
  State<ShowSelectedMediaPage> createState() => _ShowSelectedMediaPageState();
}

class _ShowSelectedMediaPageState extends State<ShowSelectedMediaPage> {
  String? base64EncodeFile;
  String? mediaUrl;
  bool isUpload = false;

  ///SCREEN WIDTH
  var width;

  ///SCREEN HEIGHT
  var height;

  @override
  void initState() {
    base64EncodeFile = Get.arguments['media'];
    mediaUrl = Get.arguments['mediaUrl'];
    isUpload = Get.arguments['isUpload'];

    if (mediaUrl != null && !mediaUrl!.contains("http")) {
      mediaUrl = "";
    }
    debugPrint("base64EncodeFile:$base64EncodeFile");
    debugPrint("mediaUrl:$mediaUrl");
    debugPrint("isUpload:$isUpload");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: false);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.topLeft,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 56, right: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    Get.back(result: false);
                  },
                ),
              ),
            ),
            (mediaUrl != null && mediaUrl != "")
                ? Center(
                    child: Container(
                      height: height * 0.72,
                      child: PhotoView(
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 3.5,
                        imageProvider: Image.network(
                          mediaUrl!,
                          errorBuilder: (context, obj, stackTrace) {
                            return Image.asset(
                                'assets/images/dummy_image.jpeg');
                          },
                        ).image,
                      ),
                    ),
                  )
                : Center(
                    child: Container(
                      height: height * 0.72,
                      child: PhotoView(
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 3.5,
                        imageProvider:
                            Image.memory(base64Decode(base64EncodeFile!)).image,
                      ),
                    ),
                  ),
            isUpload
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        backgroundColor: AppColors.tileColors,
                        onPressed: () {
                          Get.back(result: true);
                        },
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
