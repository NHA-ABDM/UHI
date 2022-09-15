import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/constants/src/doctor_setup_values.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/constants/src/provider_attributes.dart';
import 'package:hspa_app/controller/src/dashboard_controller.dart';
import 'package:hspa_app/settings/src/preferences.dart';
import 'package:hspa_app/widgets/src/vertical_spacing.dart';

import '../../../common/common.dart';
import '../../../constants/src/strings.dart';
import '../../../model/request/src/provider_service_type.dart';
import '../../../model/request/src/save_public_key_model.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DoctorProfile? _profile;
  List<ProviderServiceTypes> listProviderServiceTypes =
      <ProviderServiceTypes>[];
  late DashboardController _dashboardController;
  /// Generate a key pair.
  final encryptionAlgorithm = X25519();

  @override
  void initState() {
    _dashboardController = DashboardController();
    _dashboardController.saveFirebaseToken();
    // _dashboardController.saveSharedKey();
    _dashboardController.savePrivatePublicKeys();
    getDoctorProfile();
    //getAndSavePrivateKey();
    super.initState();
  }

  Future<void> getDoctorProfile() async {
    _profile = await DoctorProfile.getSavedProfile();
    if (_profile != null) {
      listProviderServiceTypes.clear();
      setState(() {
        debugPrint('Display name is ${_profile?.displayName}');

        if (_profile!.isTeleconsultation!) {
          listProviderServiceTypes.add(ProviderServiceTypes(
              uuid: ProviderAttributesLocal.teleconsultation,
              displayName: AppStrings().labelTeleconsultation,
              assetImage: AssetImages.teleconsultation));
        }
        if (_profile!.isPhysicalConsultation!) {
          listProviderServiceTypes.add(ProviderServiceTypes(
              uuid: ProviderAttributesLocal.physicalConsultation,
              displayName: AppStrings().labelPhysicalConsultation,
              assetImage: AssetImages.physicalConsultation));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: generateDrawer(),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.tileColors,
        shadowColor: AppColors.tileColors,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          '',
          style:
              AppTextStyle.textBoldStyle(color: AppColors.white, fontSize: 18),
        ),
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetImages.menu),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
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
                                return Image.asset(
                                    AssetImages.doctorPlaceholder);
                              },
                              placeholder: const AssetImage(
                                  AssetImages.doctorPlaceholder)),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
              VerticalSpacing(),
              Text(_profile?.displayName ?? 'Dr. Sana Bhatt',
                  style: AppTextStyle.textBoldStyle(
                      fontSize: 22, color: AppColors.drNameTextColor)),
              VerticalSpacing(size: 4),
              Text(_profile?.speciality ?? 'Cardiologist',
                  style: AppTextStyle.textSemiBoldStyle(
                      fontSize: 13, color: AppColors.drNameTextColor)),
              VerticalSpacing(size: 4),
              Text(_profile?.hprAddress ?? 'sana.bhat@hpr.abdm',
                  style: AppTextStyle.textSemiBoldStyle(
                      fontSize: 13, color: AppColors.drNameTextColor)),
              VerticalSpacing(size: 4),
              Text(AppStrings().labelHprAddress,
                  style: AppTextStyle.textNormalStyle(
                      fontSize: 13, color: AppColors.drDetailsTextColor)),
              VerticalSpacing(size: 24),
              GridView.builder(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 6,
                ),
                itemCount: listProviderServiceTypes.length,
                itemBuilder: (BuildContext context, int index) {
                  ProviderServiceTypes providerServiceType =
                      listProviderServiceTypes[index];
                  return LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    debugPrint(
                        'Width of card widget is ${constraints.maxWidth} and min width is ${constraints.minWidth}');
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.2), width: 1)),
                      child: InkWell(
                        overlayColor:
                            MaterialStateProperty.resolveWith((states) {
                          return states.contains(MaterialState.pressed)
                              ? AppColors.tileColors.withAlpha(50)
                              : null;
                        }),
                        onTap: () {
                          Get.toNamed(AppRoutes.consultationDetailsPage,
                              arguments: <String, dynamic>{
                            'consultType':providerServiceType.displayName!,
                            'isTeleconsultation':providerServiceType.uuid ==
                                ProviderAttributesLocal.teleconsultation,
                            'providerServiceTypes':providerServiceType,
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                          child: Column(
                            children: [
                              Image.asset(
                                providerServiceType.assetImage!,
                                height: constraints.maxWidth / 2,
                                width: constraints.maxWidth / 2,
                              ),
                              VerticalSpacing(
                                size: 4,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    providerServiceType.displayName!,
                                    style: AppTextStyle.textMediumStyle(
                                        fontSize: 16,
                                        color: AppColors.tileColors),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  generateDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getDrawerHeader(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              if (_profile != null && _profile!.isTeleconsultation!)
                generateDrawerListItem(
                    assetImage: AssetImages.teleconsultation,
                    label: AppStrings().labelTeleconsultation,
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.updateConsultationDetailsPage, arguments: <String, dynamic>{
                        'isTeleconsultation': true,
                      });
                    }),
              if (_profile != null && _profile!.isPhysicalConsultation!)
                generateDrawerListItem(
                    assetImage: AssetImages.physicalConsultation,
                    label: AppStrings().labelPhysicalConsultation,
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.updateConsultationDetailsPage, arguments: <String, dynamic>{
                        'isTeleconsultation': false,
                      });
                    }),
              generateDrawerListItem(
                  assetImage: AssetImages.helpSupport,
                  label: AppStrings().labelHelpAndSupport,
                  onPressed: () {
                    DialogHelper.showComingSoonView();
                    Navigator.pop(context);
                  }),
              generateDrawerListItem(
                  assetImage: AssetImages.rateUs,
                  label: AppStrings().labelRateUs,
                  onPressed: () {
                    DialogHelper.showComingSoonView();
                    Navigator.pop(context);
                  }),
              generateDrawerListItem(
                  assetImage: '',
                  icon: Icons.settings,
                  label: AppStrings().labelSettings,
                  onPressed: () async{
                    Navigator.pop(context);
                    await Get.toNamed(AppRoutes.settingsPage);
                    getDoctorProfile();
                  }),
              generateDrawerListItem(
                  assetImage: AssetImages.termsAndPolicy,
                  label: AppStrings().labelTermsOfUsePolicy,
                  onPressed: () {
                    DialogHelper.showComingSoonView();
                    Navigator.pop(context);
                  }),
              /*generateDrawerListItem(
                  assetImage: AssetImages.edit,
                  label: AppStrings().labelChangeLanguage,
                  onPressed: () async{
                    Navigator.pop(context);
                    await Get.toNamed(AppRoutes.changeLanguagePage, arguments: {'isChange': true});
                    /// We have called get doctor profile again as list view text labels are not updating with selected language
                    getDoctorProfile();
                  }),*/
              generateDrawerListItem(
                  assetImage: AssetImages.logout,
                  label: AppStrings().labelLogout,
                  onPressed: () {
                    Navigator.pop(context);
                    _dashboardController.logoutUser();
                    DoctorProfile.emptyDoctorProfile();
                    DoctorSetupValues doctorSetUpValues = DoctorSetupValues();
                    doctorSetUpValues.clear();

                    /// Removing local auth as we are logging out user
                    Preferences.saveBool(key: AppStrings.isLocalAuth, value: false);
                    Preferences.saveString(key: AppStrings.encryptionPrivateKey, value: null);
                    Get.offAllNamed(AppRoutes.userRolePage);
                  }),
            ],
          ),
        ),
      ],
    );
  }

  getDrawerHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      color: AppColors.tileColors,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CircleAvatar(
                      radius: 60.0,
                      backgroundColor: Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(110.0),
                        child: FadeInImage(
                            width: 115,
                            height: 115,
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
                Positioned(
                  bottom: 0,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      //Get.toNamed(AppRoutes.editProfilePage);
                      DialogHelper.showComingSoonView();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 12.0,
                      child: Image.asset(
                        AssetImages.edit,
                        height: 16,
                        width: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
            VerticalSpacing(
              size: 16,
            ),
            Text(_profile?.displayName ?? 'Dr. Sana Bhatt',
                style: AppTextStyle.textBoldStyle(
                    fontSize: 22, color: AppColors.white)),
            VerticalSpacing(
              size: 4,
            ),
            Text(_profile?.speciality ?? 'Cardiologist',
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 13, color: AppColors.white)),
            VerticalSpacing(
              size: 4,
            ),
            Text(_profile?.hprAddress ?? 'sana.bhat@hpr.abdm',
                style: AppTextStyle.textSemiBoldStyle(
                    fontSize: 13, color: AppColors.white)),
            VerticalSpacing(
              size: 4,
            ),
            Text(AppStrings().labelHPRAddress,
                style: AppTextStyle.textNormalStyle(
                    fontSize: 13, color: AppColors.drDetailsTextColor)),
          ],
        ),
      ),
    );
  }

  generateDrawerListItem(
      {required String assetImage,
      required String label,
      required Function() onPressed,
      IconData? icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            return states.contains(MaterialState.pressed)
                ? AppColors.tileColors.withAlpha(50)
                : null;
          }),
          onTap: onPressed,
          child: ListTile(
            leading: icon != null
                ? Icon(icon, size: 36, color: AppColors.tileColors,)
                : Image.asset(
                    assetImage,
                    height: 36,
                    width: 36,
                  ),
            title: Text(
              label,
              style: AppTextStyle.textNormalStyle(
                  fontSize: 16, color: AppColors.testColor),
            ),
            onTap: null,
          ),
        ),
        const Divider(
          color: AppColors.drawerDividerColor,
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  void getAndSavePrivateKey() async{
    String? privateKey = Preferences.getString(key: AppStrings.encryptionPrivateKey);
    if(privateKey == null) {
      SimpleKeyPair keyPair = await encryptionAlgorithm.newKeyPair();
      String privateKeyBytes =
      (await keyPair.extractPrivateKeyBytes()).toString();
      Preferences.saveString(key: AppStrings.encryptionPrivateKey, value: privateKeyBytes);
    }
  }

}
