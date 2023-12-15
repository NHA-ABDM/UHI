import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/utils/src/validator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../controller/src/auth_controller.dart';
import '../../../model/response/src/hpr_id_profile_response.dart';
import '../../../model/response/src/provider_response.dart';
import '../../../model/response/src/validate_otp_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../settings/src/preferences.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/square_rounded_button_with_icon.dart';
import '../../../widgets/src/vertical_spacing.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class OTPAuthenticationPage extends StatefulWidget {
  const OTPAuthenticationPage({Key? key}) : super(key: key);

/*  OTPAuthenticationPage({Key? key, required this.fromUserRole, required this.mobileNumber, required this.transactionId}) : super(key: key);

  final bool fromUserRole;
  final String mobileNumber;
  String transactionId;*/

  @override
  State<OTPAuthenticationPage> createState() => _OTPAuthenticationPageState();
}

class _OTPAuthenticationPageState extends State<OTPAuthenticationPage> {

  /// Arguments
  late final bool fromUserRole;
  late final String mobileNumber;
  late String transactionId;

  late AuthenticationController _authenticationController;
  bool isLoading = false;
  String otp = "";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpTextController = TextEditingController();

  @override
  void initState() {

    /// Get Arguments
    fromUserRole = Get.arguments['fromUserRole'];
    mobileNumber = Get.arguments['mobileNumber'];
    transactionId = Get.arguments['transactionId'];

    _authenticationController = AuthenticationController();
    super.initState();
  }

  @override
  void dispose() {
    _otpTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
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
      ),
    );
  }

  buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                fromUserRole ? '${AppStrings().otpAuthLabel} (+91) $mobileNumber' : AppStrings().enterOtpLabel
                , style: AppTextStyle.textSemiBoldStyle(fontSize: 14, color: AppColors.titleTextColor)),
            VerticalSpacing( size: 24,),

            Form(
              key: _formKey,
              child: PinCodeTextField(
                controller: _otpTextController,
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
                  //setState(() {
                    otp = value;
                  //});
                },
              ),
            ),

            VerticalSpacing( size: 36,),
            SquareRoundedButtonWithIcon(text: AppStrings().btnContinue, assetImage: AssetImages.arrowLongRight, onPressed: () async{
              /*if (fromUserRole) {
                    Get.offAll(const DoctorProfilePage());
                  }*/

              if(_formKey.currentState!.validate()){
                debugPrint('Opt is $otp');
                await handleAPI();
              }
                  //await handleAPI();
            }),
            VerticalSpacing( size: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings().dontReceiveOTPLabel, style: AppTextStyle.textLightStyle(fontSize: 14, color: AppColors.titleTextColor),),
                TextButton(
                    onPressed: () {
                      resendOtp();
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

  Future<void> handleAPI() async{
    if(fromUserRole) {
      setState(() {
        isLoading = true;
      });

      try {
        String? accessToken = Preferences.getString(key: AppStrings.accessToken);
        if(accessToken != null) {
          ValidateOTPResponse? validateOTPResponse = await _authenticationController.verifyMobileOtp(transactionId: transactionId, otp: otp, accessToken: accessToken);

          if(validateOTPResponse != null){
            if(validateOTPResponse.mobileLinkedHpIdDTO != null && validateOTPResponse.mobileLinkedHpIdDTO!.isNotEmpty){
              if(validateOTPResponse.mobileLinkedHpIdDTO!.length == 1 && validateOTPResponse.mobileLinkedHpIdDTO![0].hprIdNumber != null){
                await getAuthTokenForHprId(hprIdNumber: validateOTPResponse.mobileLinkedHpIdDTO![0].hprIdNumber!, transactionId: validateOTPResponse.txnId!);
              } else {
                setState(() {
                  isLoading = false;
                });

                // Get.to(() => SelectHprIdPage(validateOTPResponse: validateOTPResponse,));
                Get.toNamed(AppRoutes.selectHprIdPage, arguments: {'validateOTPResponse': validateOTPResponse});
              }
            }
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          //TODO handle refresh access token logic
        }
      } catch(e) {
        setState(() {
          isLoading = false;
        });
        debugPrint('Verify mobile otp API exception is ${e.toString()}');
      }
    } else {
      /*Get.to(() => const DoctorProfilePage(),
        transition: Utility.pageTransition,);*/
      Get.toNamed(AppRoutes.doctorProfilePage);
    }
  }

  Future<void> resendOtp() async{
    setState(() {
      isLoading = true;
    });
    String? accessToken = Preferences.getString(key: AppStrings.accessToken);
    String? transactionId = await _authenticationController.sendMobileOtp(mobileNumber: mobileNumber, accessToken: accessToken!);
    setState(() {
      isLoading = false;
    });

    if(transactionId != null) {
      _otpTextController.text = '';
      transactionId = transactionId;
    }
  }

  Future<void> getAuthTokenForHprId({required String hprIdNumber, required String transactionId}) async{
    try {
      String? accessToken = Preferences.getString(key: AppStrings.accessToken);
      if(accessToken != null) {
        String? authToken = await _authenticationController.getHprIdAuthToken(hpId: hprIdNumber, transactionId: transactionId, accessToken: accessToken);

        if(authToken != null) {
          await getDoctorProfile(authToken : authToken);
        } else {
          setState(() {
            isLoading = false;
          });
        }

      } else {
        setState(() {
          isLoading = false;
        });
        //TODO handle refresh access token logic
      }
    } catch(e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Get Auth token API exception is ${e.toString()}');
    }
  }

  getDoctorProfile({required String authToken}) async {
    try {
      String? accessToken = Preferences.getString(key: AppStrings.accessToken);
      if(accessToken != null) {
        HPRIDProfileResponse? hprIdProfileResponse = await _authenticationController.getHprIdDoctorProfile(authToken: authToken, accessToken: accessToken);

        if(hprIdProfileResponse != null){
          await checkDoctorProfilePresent(hprIdProfileResponse);
        } else {
          setState(() {
            isLoading = false;
          });
        }

      } else {
        setState(() {
          isLoading = false;
        });
        //TODO handle refresh access token logic
      }
    } catch(e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Get Auth token API exception is ${e.toString()}');
    }
  }

  checkDoctorProfilePresent(HPRIDProfileResponse hprIdProfileResponse) async {
    try {
      ProviderListResponse? providerListResponse = await _authenticationController
          .getProviderDetails(identifier: hprIdProfileResponse.hprId!);
      if (providerListResponse != null) {
        if (providerListResponse.results != null &&
            providerListResponse.results!.isNotEmpty) {
          setState(() {
            isLoading = false;
          });
          DoctorProfile? profile = await DoctorProfile.getSavedProfile();
          if (profile != null && profile.firstConsultation == null) {
            /*Get.to(() => const DoctorProfilePage(),
            transition: Utility.pageTransition,);*/
            Get.toNamed(AppRoutes.doctorProfilePage);
          } else {
            /*Get.offAll(() => const DashboardPage(),
            transition: Utility.pageTransition,);*/
            Get.offAllNamed(AppRoutes.dashboardPage);
          }
        } else {
          setState(() {
            isLoading = false;
          });

          /*Get.to(() => CompleteProviderProfilePage(hprIdProfileResponse: hprIdProfileResponse),
          transition: Utility.pageTransition,);*/
          Get.toNamed(AppRoutes.completeProviderProfilePage,
              arguments: {'hprIdProfileResponse': hprIdProfileResponse});
        }
      }
    } catch (e) {
      debugPrint('check provider profile API exception is ${e.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }
}
