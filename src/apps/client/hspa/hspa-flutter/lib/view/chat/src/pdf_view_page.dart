import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({Key? key}) : super(key: key);

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String _mediaUrl = '';
  File? file;

  @override
  void initState() {
    _mediaUrl = Get.arguments['mediaUrl'];
    debugPrint('MediaUrl is $_mediaUrl');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    //file?.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
        ),
        title: Text(
          'document',
          overflow: TextOverflow.ellipsis,
          style:
              AppTextStyle.textBoldStyle(fontSize: 18, color: AppColors.black),
        ),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<String?>(
              future: getFilePathFromPdfUrl(),
              builder: (context, snapshot) {
                debugPrint('Snapshot data is ${snapshot.data}');
                if (snapshot.hasData) {
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return PDFView(
                      filePath: snapshot.data,
                      onRender: (_pages) {
                        setState(() {
                          pages = _pages;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                        debugPrint(error.toString());
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = '$page: ${error.toString()}';
                        });
                        debugPrint('onPageError $page: ${error.toString()}');
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _controller.complete(pdfViewController);
                      },
                      onLinkHandler: (String? uri) {
                        debugPrint('onLinkHandler goto uri: $uri');
                      },
                      onPageChanged: (int? page, int? total) {
                        debugPrint('onPageChanged page change: $page/$total');
                        setState(() {
                          currentPage = page;
                        });
                      },
                    );
                  } else {
                    return Center(
                      child: Text(errorMessage),
                    );
                  }
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ],
      ),
    );
  }

  Future<String?> getFilePathFromPdfUrl() async {
    try {
      if(_mediaUrl.startsWith('http')) {
        final url = _mediaUrl;
        final filename = url.substring(url.lastIndexOf("/") + 1);
        var request = await HttpClient().getUrl(Uri.parse(url));
        var response = await request.close();
        var bytes = await consolidateHttpClientResponseBytes(response);
        var dir = await getApplicationDocumentsDirectory();
        debugPrint("Local file path is ${dir.path}/$filename");
        file = File("${dir.path}/$filename");
        await file?.writeAsBytes(bytes, flush: true);
      } else {
        file = File(_mediaUrl);
      }
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return file?.path;
  }
}
