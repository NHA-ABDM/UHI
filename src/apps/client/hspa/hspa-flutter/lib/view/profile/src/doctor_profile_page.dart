import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/model/src/doctor_profile.dart';
import 'package:hspa_app/widgets/src/square_rounded_button_with_icon.dart';
import 'package:hspa_app/widgets/src/spacing.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/doctor_setup_values.dart';
import '../../../constants/src/strings.dart';
import '../../../settings/src/preferences.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../doctor_setup/src/setup_services.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({Key? key}) : super(key: key);

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {

  DoctorProfile? _profile;

  @override
  void initState() {
    getDoctorProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.tileColors,
        shadowColor: AppColors.tileColors,
        elevation: 0,
        titleSpacing: 24,
        title: Text(
          AppStrings().profileAppBarTitle,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.white, fontSize: 18),
        ),
        /*leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),*/
        actions: [
          IconButton(
            onPressed: () {
              DoctorProfile.emptyDoctorProfile();
              DoctorSetupValues doctorSetUpValues = DoctorSetupValues();
              doctorSetUpValues.clear();

              /// Removing local auth as we are logging out user
              Preferences.saveBool(key: AppStrings.isLocalAuth, value: false);
              Preferences.saveString(
                  key: AppStrings.encryptionPrivateKey, value: null);
              Get.offAllNamed(AppRoutes.userRolePage);
            },
            icon: RotatedBox(
              quarterTurns: 3,
              child: Image.asset(
                AssetImages.logout,
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                    children: [

                      Container(
                        margin: const EdgeInsets.only(bottom: 60),
                        height: 150,
                        decoration: BoxDecoration(
                        color: AppColors.tileColors,
                        borderRadius: BorderRadius.circular(0),
                        ),
                        child: Container(
                          height: 150,
                          margin: const EdgeInsets.only(bottom: 60),
                          alignment: Alignment.center,
                          child: Text(AppStrings().labelHPRProfile, style: AppTextStyle.textMediumStyle(color: Colors.white, fontSize: 20),),
                        ),
                      ),
                      Positioned(
                        height: 200,
                        left: 10,
                        right: 10,
                        top: 10,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            child: CircleAvatar(
                              radius: 60.0,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(110.0),
                                child: FadeInImage(
                                    width: 115,
                                    height: 115,
                                    fit: BoxFit.fill,
                                    image:  (_profile != null && _profile!.profilePhoto != null)
                                        ? Image.memory(base64Decode(_profile!.profilePhoto!)).image
                                     : Image.network(
                                      AppStrings.getProfilePhoto(gender: _profile?.gender),
                                    ).image,
                                    imageErrorBuilder: (context, obj, stackTrace) {
                                      return Image.asset(AssetImages.doctorPlaceholder);
                                    },
                                    placeholder: const AssetImage(AssetImages.doctorPlaceholder)),
                              )
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
                Spacing(isWidth: false,),
                _profile == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Dr. Sana Bhatt', style: AppTextStyle.textBoldStyle(fontSize: 22, color: AppColors.drNameTextColor)),
                          Spacing(isWidth: false, size: 20,),
                          generateDetailRow(firstKey: 'Cardiologist', firstValue: AppStrings().labelDepartment, secondKey: 'Allopathy', secondValue: AppStrings().labelType),
                          generateDetailRow(firstKey: '6 Years', firstValue: AppStrings().labelExperience, secondKey: 'MBBS', secondValue: AppStrings().labelEducation),
                          generateDetailRow(firstKey: 'Hindi,English,Punjabi', firstValue: AppStrings().labelLanguages, secondKey: 'sana.bhat@hpr.abdm', secondValue: AppStrings().labelHPRAddress),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_profile!.displayName!,
                              style: AppTextStyle.textBoldStyle(
                                  fontSize: 22,
                                  color: AppColors.drNameTextColor)),
                          Spacing(
                            isWidth: false,
                            size: 20,
                          ),
                          generateDetailRow(
                              firstKey: _profile!.speciality!,
                              firstValue: AppStrings().labelDepartment,
                              secondKey: _profile!.medicineType!,
                              secondValue: AppStrings().labelType),
                          generateDetailRow(
                              firstKey: '${_profile!.experience!} ${AppStrings().labelYears}',
                              firstValue: AppStrings().labelExperience,
                              secondKey: _profile!.education!,
                              secondValue: AppStrings().labelEducation),
                          generateDetailRow(
                              firstKey: _profile!.languages!,
                              firstValue: AppStrings().labelLanguages,
                              secondKey: _profile!.hprAddress!,
                              secondValue: AppStrings().labelHPRAddress),
                        ],
                      ),
              ],
            ),
          ),
        ),
        Column(
          children: [
            Spacing(isWidth: false, size: 24,),
            Text(AppStrings().labelMoveNext, style: AppTextStyle.textMediumStyle(fontSize: 14, color: AppColors.titleTextColor)),
            Spacing(isWidth: false, size: 16,),
            SquareRoundedButtonWithIcon(text: AppStrings().btnNext, assetImage: AssetImages.arrowLongRight, onPressed: (){
              DoctorSetupValues doctorSetUpValues = DoctorSetupValues();
              doctorSetUpValues.clear();
              /*Get.to(const SetUpServicesPage(),
                transition: Utility.pageTransition,);*/
              Get.toNamed(AppRoutes.setUpServicesPage);
            }),
            Spacing(isWidth: false, size: 24,),
          ],
        ),
      ],
    );
  }

  generateDetailRow({required String firstKey, required String firstValue, required String secondKey, required String secondValue}){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: generateDrDetailsView(key: firstKey, value: firstValue)),
              const VerticalDivider(color: AppColors.dividerColor, thickness: 1, ),
              Expanded(child: generateDrDetailsView(key: secondKey, value: secondValue)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Divider(thickness: 1, color: AppColors.dividerColor,height: 1),
        ),
      ],
    );
  }

  generateDrDetailsView({required String key, required String value}) {
    return Padding(
        padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(key, style: AppTextStyle.textSemiBoldStyle(fontSize: 13, color: AppColors.drNameTextColor),textAlign: TextAlign.center,),
          Spacing(isWidth: false, size: 6,),
          Text(value, style: AppTextStyle.textNormalStyle(fontSize: 13, color: AppColors.drDetailsTextColor),textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> getDoctorProfile() async{
    _profile = await DoctorProfile.getSavedProfile();
    if(_profile != null) {
      String? profilePhoto = _profile!.profilePhoto;
      if(profilePhoto != null) {

      }
      setState(() {
        debugPrint('Display name is ${_profile?.displayName}');
      });
    }
  }
}
