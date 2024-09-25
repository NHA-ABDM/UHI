import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/authentication/registration/src/registration_otp_verification.dart';

class RegisterWithMobile extends StatefulWidget {
  const RegisterWithMobile({Key? key}) : super(key: key);

  @override
  State<RegisterWithMobile> createState() => _RegisterWithMobileState();
}

class _RegisterWithMobileState extends State<RegisterWithMobile> {
  ///CONTROLLERS
  TextEditingController searchTextEditingController = TextEditingController();
  TextEditingController symptomsTextEditingController = TextEditingController();
  final mobileNumberTextEditingController = TextEditingController();

  ///SIZE
  var width;
  var height;
  var isPortrait;

  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;

  ///DATA VARIABLES

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().registrationWithMobileNumber,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildWidgets(),
    );
  }

  navigateToOtpVerificationPage() {
    Get.to(RegistrationOTPVerificationPage(
      mobileNumber: mobileNumberTextEditingController.text,
      isFromMobile: true,
    ));
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().enterMobileNumber,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 68,
            width: width * 0.89,
            child: IntlPhoneField(
              controller: mobileNumberTextEditingController,
              textAlignVertical: TextAlignVertical.center,
              flagsButtonMargin: EdgeInsets.only(left: 8),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(top: 5),
                border:
                    OutlineInputBorder(borderSide: BorderSide(), gapPadding: 0),
              ),
              dropdownIconPosition: IconPosition.trailing,
              initialCountryCode: 'IN',
              onChanged: (phone) {},
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                //Get.to(const RegistrationWithAllDetails());
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
