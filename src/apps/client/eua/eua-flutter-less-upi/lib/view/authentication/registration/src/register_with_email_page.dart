import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/registration_otp_verification.dart';

class RegisterWithEmailPage extends StatefulWidget {
  const RegisterWithEmailPage({Key? key}) : super(key: key);

  @override
  State<RegisterWithEmailPage> createState() => _RegisterWithEmailPageState();
}

class _RegisterWithEmailPageState extends State<RegisterWithEmailPage> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool? _isChecked = false;
  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  final emailTextFieldController = TextEditingController();

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
          AppStrings().registrationWithEmail,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  navigateToOtpVerificationPage() {
    Get.to(RegistrationOTPVerificationPage(
      emailId: emailTextFieldController.text,
      isFromMobile: false,
    ));
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().enterEmail,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.doctorExperienceColor,
              ),
            ),
            child: TextFormField(
              controller: emailTextFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                border: InputBorder.none,
                hintText: AppStrings().hintEmail,
                hintStyle: AppTextStyle.textLightStyle(
                    color: AppColors.testColor, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                navigateToOtpVerificationPage();
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
      ),
    );
  }
}
