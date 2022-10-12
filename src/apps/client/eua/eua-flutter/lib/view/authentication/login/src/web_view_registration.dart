import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/src/app_colors.dart';
import 'package:uhi_flutter_app/theme/src/app_text_style.dart';

class WebViewRegistration extends StatefulWidget {
  bool? isForgotAbhaNumber;

  WebViewRegistration({this.isForgotAbhaNumber});

  @override
  WebViewRegistrationState createState() => WebViewRegistrationState();
}

class WebViewRegistrationState extends State<WebViewRegistration> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          widget.isForgotAbhaNumber != null && widget.isForgotAbhaNumber == true
              ? "Forgot ABHA Number"
              : AppStrings().registration,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: WebviewScaffold(
        url: widget.isForgotAbhaNumber != null &&
                widget.isForgotAbhaNumber == true
            ? 'https://healthidsbx.abdm.gov.in/login/recovery'
            : 'https://healthidsbx.abdm.gov.in/register',
      ),
    );
  }
}
