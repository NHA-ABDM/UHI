import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/utils/src/validator.dart';
import 'package:hspa_app/widgets/src/square_rounded_button_with_icon.dart';
import 'package:hspa_app/widgets/widgets.dart';

import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/vertical_spacing.dart';
import 'aadhaar_otp_auth_page.dart';

class SignUpWithAadhaarPage extends StatefulWidget {
  const SignUpWithAadhaarPage({Key? key}) : super(key: key);

  @override
  State<SignUpWithAadhaarPage> createState() => _SignUpWithAadhaarPageState();
}

class _SignUpWithAadhaarPageState extends State<SignUpWithAadhaarPage> {
  bool isChecked = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().signUpWithAadhaarAppBarTitle,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
          onPressed: () {
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings().labelSendOtpToLinkedNumber,
                style: AppTextStyle.textSemiBoldStyle(
                    color: AppColors.titleTextColor, fontSize: 14),
              ),
              Spacing(
                isWidth: false,
                size: 36,
              ),
              Text(
                AppStrings().labelAadhaarNoVirtualOd,
                style: AppTextStyle.textMediumStyle(
                    fontSize: 12, color: AppColors.labelTextColor),
              ),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(),
                maxLength: 12,
                decoration: const InputDecoration(
                  counterText: ''
                ),
                autovalidateMode: _autoValidateMode,
                validator: (String? aadhaar) {
                  return Validator.validateAadhaar(aadhaar);
                },
              ),
              Spacing(
                isWidth: false,
                size: 12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? checked) {
                      if (checked != null) {
                        setState(() {
                          isChecked = checked;
                        });
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    side: MaterialStateBorderSide.resolveWith(
                      (states) =>
                          const BorderSide(width: 1.0, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings().labelAadhaarTermsCondition,
                            style: AppTextStyle.textNormalStyle(
                                color: AppColors.black, fontSize: 12),
                          ),
                          Spacing(
                            isWidth: false,
                            size: 4,
                          ),
                          Text(
                            AppStrings().labelTermsCondition,
                            style: AppTextStyle.textBoldStyle(
                                color: AppColors.black, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              VerticalSpacing(size: 36,),
              SquareRoundedButtonWithIcon(text: AppStrings().btnContinue, assetImage: AssetImages.arrowLongRight, onPressed: (){
                if(formKey.currentState!.validate()){
                  Get.to(() => const AadhaarOTPAuthenticationPage(),
                    transition: Utility.pageTransition,);
                } else {
                  setState(() {
                    _autoValidateMode = AutovalidateMode.always;
                  });
                }

              }),
            ],
          ),
        ),
      ),
    );
  }
}
