import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/asset_images.dart';
import '../../../constants/src/get_pages.dart';
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

class SelectHprIdPage extends StatefulWidget {
  const SelectHprIdPage({Key? key}) : super(key: key);

  /*const SelectHprIdPage({Key? key, required this.validateOTPResponse}) : super(key: key);
  final ValidateOTPResponse validateOTPResponse;*/

  @override
  State<SelectHprIdPage> createState() => _SelectHprIdPageState();
}

class _SelectHprIdPageState extends State<SelectHprIdPage> {

  /// Arguments
  late final ValidateOTPResponse validateOTPResponse;

  late AuthenticationController _authenticationController;
  String? _selectedHprId;
  bool _isLoading = false;

  @override
  void initState() {

    /// Get Arguments
    validateOTPResponse = Get.arguments['validateOTPResponse'];

    _authenticationController = AuthenticationController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBackgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 0,
          title: Text(
            AppStrings().titleSelectHprId,
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
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().labelSelectHprId,
            style: AppTextStyle.textSemiBoldStyle(
              fontSize: 14,
              color: AppColors.titleTextColor,
            ),
          ),
          VerticalSpacing( size: 12,),
          Expanded(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => VerticalSpacing(),
                shrinkWrap: true,
                  itemCount: validateOTPResponse.mobileLinkedHpIdDTO!.length,
                  itemBuilder: (BuildContext context, int index) {
                  MobileLinkedHpIdDTO dto = validateOTPResponse.mobileLinkedHpIdDTO![index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.doctorExperienceColor,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: RadioListTile<String>(
                        //dense: true,
                        //contentPadding: EdgeInsets.zero,
                        value: dto.hprIdNumber!,
                        groupValue: _selectedHprId,
                        onChanged: (value) {
                          setState(() {
                            _selectedHprId = value!;
                            debugPrint('SelectedHprId:$_selectedHprId');
                          });
                        },
                        title: Text(
                          dto.hprIdNumber!,
                          style: AppTextStyle.textNormalStyle(
                              fontSize: 16, color: AppColors.black),
                        ),
                      ),
                    );
                  },
              ),
          ),

          VerticalSpacing(size: 12,),
          SquareRoundedButtonWithIcon(text: AppStrings().btnContinue, assetImage: AssetImages.arrowLongRight, onPressed: () {
            if(_selectedHprId == null) {
              Get.snackbar(AppStrings().alert, AppStrings().labelSelectHprId);
            } else {
              handleApi();
            }
          }),
        ],
      ),
    );
  }

  void handleApi() async{
    setState(() {
      _isLoading = true;
    });
    await getAuthTokenForHprId(hprIdNumber: _selectedHprId!, transactionId: validateOTPResponse.txnId!);
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
            _isLoading = false;
          });
        }

      } else {
        setState(() {
          _isLoading = false;
        });
        //TODO handle refresh access token logic
      }
    } catch(e) {
      setState(() {
        _isLoading = false;
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
            _isLoading = false;
          });
        }

      } else {
        setState(() {
          _isLoading = false;
        });
        //TODO handle refresh access token logic
      }
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Get Auth token API exception is ${e.toString()}');
    }
  }

  checkDoctorProfilePresent(HPRIDProfileResponse hprIdProfileResponse) async {
    ProviderListResponse? providerListResponse = await _authenticationController
        .getProviderDetails(identifier: hprIdProfileResponse.hprId!);
    if (providerListResponse != null) {
      if (providerListResponse.results != null &&
          providerListResponse.results!.isNotEmpty) {
        setState(() {
          _isLoading = false;
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
          _isLoading = false;
        });

        /*Get.to(() => CompleteProviderProfilePage(hprIdProfileResponse: hprIdProfileResponse),
          transition: Utility.pageTransition,);*/
        Get.toNamed(AppRoutes.completeProviderProfilePage, arguments: {'hprIdProfileResponse': hprIdProfileResponse});
      }
    }
  }
}
