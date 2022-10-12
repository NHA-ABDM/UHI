import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/authentication/authentication.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/registration_otp_verification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/common.dart';
import '../../../../controller/login/login.dart';
import '../../../../model/common/common.dart';

class AbhaAuthMethodsPage extends StatefulWidget {
  String healthIdNumber;

  AbhaAuthMethodsPage({Key? key, required this.healthIdNumber})
      : super(key: key);

  @override
  State<AbhaAuthMethodsPage> createState() => _AbhaAuthMethodsPageState();
}

class _AbhaAuthMethodsPageState extends State<AbhaAuthMethodsPage> {
  ///CONTROLLERS
  AbhaNumberController _abhaNumberController = AbhaNumberController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;

  String _selectedOption = 'AADHAAR_OTP';
  final Uri _url = Uri.parse('https://healthidsbx.abdm.gov.in/register');

  ///DATA VARIABLES
  bool isLoading = false;

  ///ABHA AUTH MODE API
  postAbhaAuthModeAPI() async {
    _abhaNumberController.refresh();
    showProgressIndicator();

    AbhaIdAuthModel abhaIdAuthModel = AbhaIdAuthModel();
    abhaIdAuthModel.healthid = widget.healthIdNumber;
    abhaIdAuthModel.authMethod = _selectedOption;

    log("${jsonEncode(abhaIdAuthModel)}", name: "ABHA AUTH MODE MODEL");

    await _abhaNumberController.postAbhaAuthDetails(
        abhaAuthDetails: abhaIdAuthModel);

    if (_abhaNumberController.abhaAuthAckDetails != null &&
        _abhaNumberController.abhaAuthAckDetails != "") {
      hideProgressIndicator();

      String? sessionId = _abhaNumberController.abhaAuthAckDetails["sessionId"];
      log("$sessionId");

      if (sessionId != null && sessionId.isNotEmpty) {
        Get.to(() => RegistrationOTPVerificationPage(
              sessionId: sessionId,
              isFromMobile: true,
              mobileNumber: "",
              isFromHealthId: true,
            ));
      } else {
        DialogHelper.showErrorDialog(
            title: AppStrings().errorString,
            description: AppStrings().somethingWentWrongErrorMsg);
      }
    } else if (_abhaNumberController.errorString != '') {
      hideProgressIndicator();
    } else {
      hideProgressIndicator();
      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
    }
  }

  showProgressIndicator() {
    setState(() {
      isLoading = true;
    });
  }

  hideProgressIndicator() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

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
          AppStrings().registrationWithABHANUmber,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  buildWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
          child: Text(
            "Select below option to send OTP",
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListTile(
            dense: true,
            leading: Radio<String>(
              value: "AADHAAR_OTP",
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            title: Transform.translate(
              offset: Offset(-20, 0),
              child: Text(
                "Send AADHAR OTP",
              ),
            ),
          ),
        ),
        ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListTile(
            dense: true,
            leading: Radio<String>(
              value: "MOBILE_OTP",
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            title: Transform.translate(
              offset: Offset(-20, 0),
              child: Text(
                "Send Mobile OTP",
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Center(
          child: GestureDetector(
            onTap: isLoading
                ? () {}
                : () {
                    postAbhaAuthModeAPI();
                  },
            child: Container(
              height: 50,
              width: width * 0.89,
              decoration: const BoxDecoration(
                color: AppColors.tileColors,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        AppStrings().btnContinue,
                        style: AppTextStyle.textMediumStyle(
                            color: AppColors.white, fontSize: 16),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }
}
