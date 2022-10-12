import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebUrls{
  static const String hprProdUrl = 'https://hprid.abdm.gov.in/register';
  static const String hprBetaUrl = 'https://hpridbeta.abdm.gov.in/register';
  static const String hprSandboxUrl = 'https://hpridsbx.abdm.gov.in/register';
  static const String hprRegistrationUrl = hprBetaUrl;

  static void launchWebUrl({required String webUrl}) async {
    final Uri _url = Uri.parse(webUrl);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication, webOnlyWindowName: 'HSPA')) {
      throw 'Could not launch $_url';
    }
  }
}