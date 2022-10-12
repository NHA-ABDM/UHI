import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/authentication/authentication.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../login/src/web_view_registration.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;

  String _selectedOption = 'ABHA Number';
  final Uri _url = Uri.parse('https://healthidsbx.abdm.gov.in/register');

  ///DATA VARIABLES

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
          AppStrings().registration,
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
            AppStrings().wantToCreateAbhaAddress,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListTile(
            dense: true,
            leading: Radio<String>(
              value: AppStrings().abhaNumberText,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            title: Transform.translate(
              offset: Offset(-20, 0),
              child: Row(
                children: [
                  Text(AppStrings().abhaNumberText),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    AppStrings().dontHaveABHANumber,
                    style: AppTextStyle.textNormalStyle(
                        color: AppColors.doctorExperienceColor, fontSize: 10),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: () {
                      // _launchUrl();
                      Get.to(() => WebViewRegistration());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        AppStrings().createNew,
                        style: AppTextStyle.textMediumStyle(
                            color: AppColors.paymentButtonBackgroundColor,
                            fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListTile(
            dense: true,
            leading: Radio<String>(
              value: AppStrings().mobileNumber,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            title: Transform.translate(
              offset: Offset(-20, 0),
              child: Text(AppStrings().mobileNumber),
            ),
          ),
        ),
        ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListTile(
            dense: true,
            leading: Radio<String>(
              value: AppStrings().emailId,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            title: Transform.translate(
              offset: Offset(-20, 0),
              child: Text(AppStrings().emailId),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              debugPrint("_selectedOption:$_selectedOption");
              if (_selectedOption == "ABHA Number") {
                Get.to(() => const RegisterWithAbhaNumberPage());
              } else if (_selectedOption == "Mobile Number") {
                Get.to(() => const RegisterWithMobile());
              } else {
                Get.to(() => const RegisterWithEmailPage());
              }
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
                child: Text(
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
