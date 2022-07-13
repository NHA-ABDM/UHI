import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../utils/src/validator.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import 'mobile_number_auth_page.dart';

class AadhaarOTPAuthenticationPage extends StatefulWidget {
  const AadhaarOTPAuthenticationPage({Key? key}) : super(key: key);

  @override
  State<AadhaarOTPAuthenticationPage> createState() => _AadhaarOTPAuthenticationPageState();
}

class _AadhaarOTPAuthenticationPageState extends State<AadhaarOTPAuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().otpAuthAppBarTitle,
          style: AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black,),
          onPressed: (){
            Get.back();
          },
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings().labelEnterAadhaarOtp, style: AppTextStyle.textSemiBoldStyle(fontSize: 14, color: AppColors.titleTextColor)),
            VerticalSpacing( size: 24,),

            PinCodeTextField(
              textStyle: AppTextStyle.textBoldStyle(color: AppColors.titleTextColor, fontSize: 24),
              appContext: context,
              length: 6,
              animationType: AnimationType.fade,
              validator: (v) {
                return Validator.validateOtp(v);
              },
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  fieldHeight: 30,
                  fieldWidth: 40,
                  selectedFillColor: AppColors.titleTextColor,
                  activeFillColor: AppColors.titleTextColor,
                  inactiveFillColor: AppColors.titleTextColor,
                  selectedColor: AppColors.titleTextColor,
                  inactiveColor: AppColors.titleTextColor.withAlpha(50),
                  activeColor: AppColors.titleTextColor,
                  borderWidth: 1),
              cursorColor: AppColors.titleTextColor.withAlpha(80),
              cursorHeight: 20,
              enableActiveFill: false,
              keyboardType: TextInputType.number,
              onCompleted: (v) {
                debugPrint("Completed:$v");
              },
              onChanged: (value) {
                setState(() {
                  // currentText = value;
                });
              },
            ),

            VerticalSpacing( size: 36,),
            SquareRoundedButtonWithIcon(text: AppStrings().btnContinue, assetImage: AssetImages.arrowLongRight, onPressed: () {
              Get.to(() => const MobileNumberAuthPage(fromRolePage: false,),
                transition: Utility.pageTransition,);
            }),
            VerticalSpacing( size: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings().dontReceiveOTPLabel, style: AppTextStyle.textLightStyle(fontSize: 14, color: AppColors.titleTextColor),),
                TextButton(
                  onPressed: () {
                  },
                  child: Text(AppStrings().btnResend,
                    style: AppTextStyle.textSemiBoldStyle(
                        fontSize: 16,
                        color: AppColors.tileColors,
                        decoration: TextDecoration.underline
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
