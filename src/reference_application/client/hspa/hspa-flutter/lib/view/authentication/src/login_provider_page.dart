import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/utils/src/validator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/strings.dart';
import '../../../controller/src/auth_controller.dart';
import '../../../model/response/src/provider_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import '../../dashboard/src/dashboard_page.dart';
import '../../profile/src/doctor_profile_page.dart';
import '../../profile/src/profile_not_found_page.dart';
import 'register_provider_page.dart';

class LoginProviderPage extends StatefulWidget {
  const LoginProviderPage({Key? key, required this.fromRolePage}) : super(key: key);

  final bool fromRolePage;

  @override
  State<LoginProviderPage> createState() => _LoginProviderPageState();
}

class _LoginProviderPageState extends State<LoginProviderPage> {
  late double width;
  final TextEditingController _hprAddressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _hprAddressController.dispose();
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
            AppStrings().providerAuthAppBarTitle,
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
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.fromRolePage ? AppStrings().enterHprAddressLabel : AppStrings().willSedOTPLabel,
                style: AppTextStyle.textSemiBoldStyle(
                  fontSize: 14,
                  color: AppColors.titleTextColor,
                ),
              ),
              VerticalSpacing( size: 24,),
              TextFormField(
                controller: _hprAddressController,
                cursorColor: AppColors.titleTextColor,
                textInputAction: TextInputAction.done,
                autovalidateMode: _autoValidateMode,
                style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.titleTextColor),
                decoration: InputDecoration(
                    labelText: AppStrings().labelHPRAddress,
                    labelStyle: AppTextStyle.textLightStyle(fontSize: 14, color: AppColors.feesLabelTextColor),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.titleTextColor))
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (String? value) {
                 return Validator.validateHprAddress(value);
                },
              ),
              VerticalSpacing(size: 24,),
              SquareRoundedButtonWithIcon(text: AppStrings().btnLogin, assetImage: AssetImages.arrowLongRight, onPressed: () async{
                  if(_formKey.currentState!.validate()) {
                    await handleAPI();
                  } else {
                    setState(() {
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
                    //WebUrls.launchWebUrl(webUrl: WebUrls.hprSandboxUrl);
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

  Future<void> handleAPI() async{
    if(widget.fromRolePage) {
      setState(() {
        _isLoading = true;
      });

      try {
        String providerHprAddress = _hprAddressController.text.trim();
        AuthenticationController authenticationController = AuthenticationController();
        ProviderListResponse? providerListResponse = await authenticationController.getProviderDetails(identifier: providerHprAddress);
        setState(() {
          _isLoading = false;
        });
        if(providerListResponse != null) {
          if(providerListResponse.results != null && providerListResponse.results!.isNotEmpty) {
            DoctorProfile? profile = await DoctorProfile.getSavedProfile();
            if (profile != null && profile.firstConsultation == null) {
              Get.to(() => const DoctorProfilePage(),
                transition: Utility.pageTransition,);
            } else {
              Get.offAll(() => const DashboardPage(),
                transition: Utility.pageTransition,);
            }
          } else {
            DoctorProfile.emptyDoctorProfile();
            bool isRefresh = await Get.to(() => const ProfileNotFoundPage(),
              transition: Utility.pageTransition,);
            if(isRefresh){
              setState(() {
                _hprAddressController.text = '';
              });
            }
          }
        } else {

        }
      } catch(e) {
        debugPrint('Get Provider details API exception is ${e.toString()}');
      }
    } else {
      Get.to(() => const DoctorProfilePage(),
        transition: Utility.pageTransition,);
    }
  }
}
