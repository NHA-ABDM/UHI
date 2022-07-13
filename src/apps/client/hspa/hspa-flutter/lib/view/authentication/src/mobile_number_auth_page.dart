import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/model/response/src/access_token_response.dart';
import 'package:hspa_app/settings/src/preferences.dart';
import 'package:hspa_app/utils/src/validator.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/strings.dart';
import '../../../constants/src/web_urls.dart';
import '../../../controller/src/auth_controller.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/alert_dialog_with_single_action.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import 'otp_auth_page.dart';
import 'register_provider_page.dart';

class MobileNumberAuthPage extends StatefulWidget {
  const MobileNumberAuthPage({Key? key, required this.fromRolePage}) : super(key: key);

  final bool fromRolePage;

  @override
  State<MobileNumberAuthPage> createState() => _MobileNumberAuthPageState();
}

class _MobileNumberAuthPageState extends State<MobileNumberAuthPage> {
  late double width;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  String mobileNumber = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width  = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBackgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 0,
          title: Text(
            AppStrings().mobileNumberAuthAppBarTitle,
            style: AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.black,),
            onPressed: (){
              Get.back();
            },
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.fromRolePage ? AppStrings().enterMobileNumberLabel : AppStrings().willSedOTPLabel,
                  style: AppTextStyle.textSemiBoldStyle(
                      fontSize: 14,
                      color: AppColors.titleTextColor,
                  ),
              ),
              VerticalSpacing( size: 24,),
              Text(
                  AppStrings().labelMobileNumber, style: AppTextStyle.textMediumStyle(fontSize: 12, color: AppColors.labelTextColor)),
              SizedBox(
                height: 70,
                child: IntlPhoneField(
                  textAlignVertical: TextAlignVertical.center,
                  dropdownIconPosition: IconPosition.trailing,
                  initialCountryCode: 'IN',
                  showCountryFlag: false,
                  showDropdownIcon: false,
                  countries: const ['IN'],
                  style: AppTextStyle.textMediumStyle(fontSize: 16, color: AppColors.titleTextColor),
                  disableLengthCheck: true,
                  validator: (PhoneNumber? number) {
                    return Validator.validateMobileNumber(number!.number);
                  },
                  onChanged: (phone) {
                    mobileNumber = phone.number;
                  },
                  autovalidateMode: _autoValidateMode,
                ),
              ),
              VerticalSpacing(size: 24,),
              SquareRoundedButtonWithIcon(text: AppStrings().btnContinue, assetImage: AssetImages.arrowLongRight, onPressed: () {
                if(_formKey.currentState!.validate() && mobileNumber.length == 10) {
                  /*Get.to(() =>
                      OTPAuthenticationPage(fromUserRole: widget.fromRolePage,),
                    transition: Utility.pageTransition,);*/
                  handleApi();
                } else {
                  setState(() {
                    if(mobileNumber.isEmpty) {
                      Get.snackbar(AppStrings().alert, AppStrings().errorEnterMobileNumber);
                    }
                    _autoValidateMode = AutovalidateMode.always;
                  });
                }
              }),

              VerticalSpacing( size: 24,),
              if(widget.fromRolePage) Text(AppStrings().dontHaveHPIDLabel, style: AppTextStyle.textMediumStyle(fontSize: 14, color: AppColors.textColor)),
              VerticalSpacing( size: 8,),
              if(widget.fromRolePage) SquareRoundedButtonWithIcon(
                  text: AppStrings().btnRegister,
                  assetImage: AssetImages.pageEdit,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  textColor: AppColors.tileColors,
                  borderColor: AppColors.tileColors,
                  onPressed: () {
                    /*Get.to(() => const SignUpPage(),
                      transition: Utility.pageTransition,);*/
                    //WebUrls.launchWebUrl(webUrl: WebUrls.hprBetaUrl);
                    Get.to(() => const RegisterProviderPage(),
                      transition: Utility.pageTransition,);
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleApi() async{
    if(widget.fromRolePage) {
      setState(() {
        _isLoading = true;
      });

      try {
        AuthenticationController authenticationController = AuthenticationController();
        AccessTokenResponse? accessTokenResponse = await authenticationController.getSessionToken();
        if(accessTokenResponse?.accessToken != null) {
          Preferences.saveString(key: AppStrings.accessToken, value: accessTokenResponse?.accessToken!);
          String? transactionId = await authenticationController.sendMobileOtp(mobileNumber: mobileNumber, accessToken: accessTokenResponse!.accessToken!);
          setState(() {
            _isLoading = false;
          });

          if(transactionId != null) {
            Get.to(() =>
                OTPAuthenticationPage(
                  fromUserRole: widget.fromRolePage,
                  mobileNumber: mobileNumber,
                  transactionId: transactionId,
                ),
              transition: Utility.pageTransition,);
          }
        } else {
          setState(() {
            _isLoading = false;
          });

          AlertDialogWithSingleAction(context: context,
            title: AppStrings().errorUnableToFetchAuthToken,
            showIcon: false,
            onCloseTap: () {
              Navigator.of(context).pop();
            },).showAlertDialog();
        }
      } catch(e) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Send mobile OTP API exception is ${e.toString()}');
      }
    }
  }
}
