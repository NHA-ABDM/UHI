import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/theme/src/app_colors.dart';
import 'package:photo_view/photo_view.dart';

import '../../../constants/src/asset_images.dart';

class ShowSelectedMediaPage extends StatefulWidget {
  const ShowSelectedMediaPage({Key? key}) : super(key: key);

  @override
  State<ShowSelectedMediaPage> createState() => _ShowSelectedMediaPageState();
}

class _ShowSelectedMediaPageState extends State<ShowSelectedMediaPage> {
  String? base64EncodeFile;
  bool isUpload = false;

  @override
  void initState() {
    base64EncodeFile = Get.arguments['media'];
    isUpload = Get.arguments['isUpload'];
    super.initState();
  }

  buildMediaWidget({required String? mediaUrl}) {
    Uint8List? base64DecodedFile;
    if (mediaUrl != null && !mediaUrl.contains("http")) {
      base64DecodedFile = base64Decode(mediaUrl);
    }
    debugPrint('Base64 decoded string is $base64DecodedFile');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // color: AppColors.greyDDDDDD,
        /*image: DecorationImage(
          image: base64DecodedFile == null
              ? Image.network(
                  mediaUrl!,
                  errorBuilder: (context, obj, stackTrace) {
                    return Image.asset(AssetImages.doctorPlaceholder);
                  },
                ).image
              : Image.memory(base64DecodedFile).image,
          fit: BoxFit.contain,
        ),*/
      ),
      child: PhotoView(
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 3.5,
        imageProvider: base64DecodedFile == null
            ? Image.network(mediaUrl!,
                errorBuilder: (context, obj, stackTrace) {
                return Image.asset(AssetImages.doctorPlaceholder);
              }, fit: BoxFit.contain).image
            : Image.memory(base64DecodedFile, fit: BoxFit.contain).image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: buildMediaWidget(mediaUrl: base64EncodeFile!)
              /*Container(
                //height: 220,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // color: AppColors.greyDDDDDD,
                  image: DecorationImage(
                    image: Image.memory(
                        base64Decode(base64EncodeFile!))
                        .image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),*/
            ),
            if (isUpload)
              Padding(
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
              ),
          ],
        ),
      ),
    );
  }
}
