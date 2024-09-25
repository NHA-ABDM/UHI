import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/utils/src/utility.dart';
import 'package:hspa_app/widgets/src/spacing.dart';
import '../../../constants/src/asset_images.dart';
import '../../../constants/src/strings.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/new_confirmation_dialog.dart';
import '../../../widgets/src/vertical_spacing.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool teleconsultationValue = true;
  bool physicalConsultationValue = false;
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
        titleSpacing: 0,
        title: Text(
          AppStrings().editProfileAppBarTitle,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.white,
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
    debugPrint('device width is ${MediaQuery.of(context).size.width}');
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Stack(children: [
            Container(
              margin: const EdgeInsets.only(bottom: 60),
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.tileColors,
                borderRadius: BorderRadius.circular(0),
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
                      radius: Utility.getRadius(context: context),
                      backgroundColor: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular((Utility.getRadius(context: context)! * 2)),
                        child: FadeInImage(
                            width: (Utility.getRadius(context: context)! * 2 - 5),
                            height: (Utility.getRadius(context: context)! * 2 - 5),
                            fit: BoxFit.fill,
                            image: (_profile != null &&
                                    _profile!.profilePhoto != null)
                                ? Image.memory(
                                        base64Decode(_profile!.profilePhoto!))
                                    .image
                                : Image.network(
                                    AppStrings.getProfilePhoto(
                                        gender: _profile?.gender),
                                  ).image,
                            imageErrorBuilder: (context, obj, stackTrace) {
                              return Image.asset(AssetImages.doctorPlaceholder);
                            },
                            placeholder: const AssetImage(
                                AssetImages.doctorPlaceholder)),
                      )),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: Utility.getRightAlignment(context: context),
              child: InkWell(
                onTap: () {},
                child: const CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.tileColors,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 12.0,
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppColors.tileColors,
                    ),
                  ),
                ),
              ),
            )
          ]),
          const Spacing(
            isWidth: false,
          ),
          Text(_profile?.displayName ?? 'Dr. Sana Bhatt',
              style: AppTextStyle.textBoldStyle(
                  fontSize: 22, color: AppColors.drNameTextColor)),
          const Spacing(
            isWidth: false,
            size: 20,
          ),
          generateDetailRow(
              firstKey: _profile?.speciality ?? 'Cardiologist',
              firstValue: AppStrings().labelDepartment,
              secondKey: 'Allopathy',
              secondValue: AppStrings().labelType),
          generateDetailRow(
              firstKey: _profile?.experience ?? '6 Years',
              firstValue: AppStrings().labelExperience,
              secondKey: _profile?.education ?? 'MBBS',
              secondValue: AppStrings().labelEducation),
          generateDetailRow(
              firstKey: _profile?.languages ?? 'Hindi,English,Punjabi',
              firstValue: AppStrings().labelLanguages,
              secondKey: _profile?.hprAddress ?? 'sana.bhat@hpr.abdm',
              secondValue: AppStrings().labelHPRAddress),
          VerticalSpacing(size: 24),
          Container(
            margin: const EdgeInsets.only(left: 24, right: 16),
            width: MediaQuery.of(context).size.width,
            child: Text(
              AppStrings().labelServicesOffered,
              style: AppTextStyle.textBoldStyle(
                  fontSize: 18, color: AppColors.black),
            ),
          ),
          VerticalSpacing(size: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacing(size: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.2), width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: Column(
                          children: [
                            Image.asset(
                              AssetImages.teleconsultation,
                              height: 60,
                              width: 60,
                            ),
                            VerticalSpacing(
                              size: 4,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  AppStrings().labelTeleconsultation,
                                  style: AppTextStyle.textNormalStyle(
                                      fontSize: 16, color: AppColors.testColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            VerticalSpacing(
                              size: 4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      AssetImages.edit,
                                      height: 20,
                                      width: 20,
                                    )),
                                Switch(
                                  value: teleconsultationValue,
                                  onChanged: (bool value) {
                                    if (teleconsultationValue) {
                                      NewConfirmationDialog(
                                          context: context,
                                          title:
                                              AppStrings().labelServicesOffered,
                                          titleTextStyle:
                                              AppTextStyle.textBoldStyle(
                                                  color: AppColors.black,
                                                  fontSize: 18),
                                          subTitle: AppStrings()
                                              .labelAlertStopConsultation(
                                                  consultType: AppStrings()
                                                      .labelTeleconsultation
                                                      .toLowerCase()),
                                          showSubtitle: true,
                                          description: AppStrings().alertNote(
                                              consultType: AppStrings()
                                                  .labelTeleconsultation
                                                  .toLowerCase()),
                                          submitButtonText:
                                              AppStrings().confirm,
                                          onCancelTap: () {
                                            Navigator.pop(context);
                                          },
                                          onSubmitTap: () {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              teleconsultationValue =
                                                  !teleconsultationValue;
                                            });
                                          }).showAlertDialog();
                                    } else {
                                      setState(() {
                                        teleconsultationValue =
                                            !teleconsultationValue;
                                      });
                                    }
                                  },
                                  activeColor: AppColors.white,
                                  activeTrackColor: AppColors.tileColors,
                                  inactiveTrackColor: AppColors.grey8B8B8B,
                                  inactiveThumbColor: AppColors.white,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacing(size: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.2), width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: Column(
                          children: [
                            Image.asset(
                              AssetImages.physicalConsultation,
                              height: 60,
                              width: 60,
                            ),
                            VerticalSpacing(
                              size: 4,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    AppStrings().labelPhysicalConsultation,
                                    style: AppTextStyle.textNormalStyle(
                                        fontSize: 16,
                                        color: AppColors.testColor),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            VerticalSpacing(
                              size: 4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      AssetImages.edit,
                                      height: 20,
                                      width: 20,
                                    )),
                                Switch(
                                  value: physicalConsultationValue,
                                  onChanged: (bool value) {
                                    if (physicalConsultationValue) {
                                      NewConfirmationDialog(
                                          context: context,
                                          title:
                                              AppStrings().labelServicesOffered,
                                          titleTextStyle:
                                              AppTextStyle.textBoldStyle(
                                                  color: AppColors.black,
                                                  fontSize: 18),
                                          subTitle: AppStrings()
                                              .labelAlertStopConsultation(
                                                  consultType: AppStrings()
                                                      .labelPhysicalConsultation
                                                      .toLowerCase()),
                                          showSubtitle: true,
                                          description: AppStrings().alertNote(
                                              consultType: AppStrings()
                                                  .labelPhysicalConsultation
                                                  .toLowerCase()),
                                          submitButtonText:
                                              AppStrings().confirm,
                                          onCancelTap: () {
                                            Navigator.pop(context);
                                          },
                                          onSubmitTap: () {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              physicalConsultationValue =
                                                  !physicalConsultationValue;
                                            });
                                          }).showAlertDialog();
                                    } else {
                                      setState(() {
                                        physicalConsultationValue =
                                            !physicalConsultationValue;
                                      });
                                    }
                                  },
                                  activeColor: AppColors.white,
                                  activeTrackColor: AppColors.tileColors,
                                  inactiveTrackColor: AppColors.grey8B8B8B,
                                  inactiveThumbColor: AppColors.white,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacing(size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  generateDetailRow(
      {required String firstKey,
      required String firstValue,
      required String secondKey,
      required String secondValue}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child:
                      generateDrDetailsView(key: firstKey, value: firstValue)),
              const VerticalDivider(
                color: AppColors.dividerColor,
                thickness: 1,
              ),
              Expanded(
                  child: generateDrDetailsView(
                      key: secondKey, value: secondValue)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child:
              Divider(thickness: 1, color: AppColors.dividerColor, height: 1),
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
          Text(
            key,
            style: AppTextStyle.textSemiBoldStyle(
                fontSize: 13, color: AppColors.drNameTextColor),
          ),
          const Spacing(
            isWidth: false,
            size: 6,
          ),
          Text(
            value,
            style: AppTextStyle.textNormalStyle(
                fontSize: 13, color: AppColors.drDetailsTextColor),
          ),
        ],
      ),
    );
  }

  Future<void> getDoctorProfile() async {
    _profile = await DoctorProfile.getSavedProfile();
    if (_profile != null) {
      setState(() {
        debugPrint('Display name is ${_profile?.displayName}');
      });
    }
  }
}
