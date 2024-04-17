import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uhi_flutter_app/common/src/dialog_helper.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/base_login_page.dart';
import 'package:uhi_flutter_app/view/home/src/change_language_page.dart';
import 'package:uhi_flutter_app/widgets/src/new_confirmation_dialog.dart';

import '../../../controller/login/src/logout_controller.dart';
import '../../../model/model.dart';
import '../../../model/response/src/get_user_details_response.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool _loading = false;
  bool status = true;
  bool isLocalAuth = false;
  String? userData;
  GetUserDetailsResponse? getUserDetailsResponseModel;
  final postLogoutController = Get.put(LogoutController());

  ///DATA VARIABLES
  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getUserData().then((value) => setState(() {
          setState(() {
            userData = value;
            getUserDetailsResponseModel =
                GetUserDetailsResponse.fromJson(jsonDecode(userData!));
          });
        }));

    SharedPreferencesHelper.getLocalAuth().then((value) => setState(() {
          setState(() {
            debugPrint("Printing the shared preference _isLocalAuth : $value");
            if (value != null) {
              isLocalAuth = value;
            }
          });
        }));
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          shadowColor: Colors.black.withOpacity(0.1),
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
          titleSpacing: 0,
          title: Text(
            AppStrings().setting,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 16),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          dismissible: false,
          progressIndicator: const CircularProgressIndicator(
            backgroundColor: AppColors.DARK_PURPLE,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
          ),
          child: buildWidgets(),
        ));
  }

  buildWidgets() {
    return ListView(
      shrinkWrap: true,
      children: [
        Card(
          margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
                  child: Text(
                    AppStrings().labelSettingsAndPreferences,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, top: 8, bottom: 0, right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings().showNotification,
                        style: AppTextStyle.textNormalStyle(
                            fontSize: 16, color: AppColors.testColor),
                      ),
                      Switch(
                        value: status,
                        onChanged: (value) {
                          setState(() {
                            status = value;
                          });
                        },
                        activeTrackColor: AppColors.doctorNameColor,
                        activeColor: AppColors.white,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    AppStrings().labelChangeLanguage,
                    style: AppTextStyle.textNormalStyle(
                        fontSize: 16, color: AppColors.testColor),
                  ),
                  subtitle: Text(
                    Get.locale.toString() == "en"
                        ? AppStrings().labelEnglish
                        : AppStrings().labelHindi,
                    style: AppTextStyle.textNormalStyle(
                        fontSize: 12, color: AppColors.testColor),
                  ),
                  trailing: const Icon(
                    Icons.navigate_next,
                    size: 36,
                    color: AppColors.testColor,
                  ),
                  contentPadding: const EdgeInsets.only(
                      left: 20, top: 0, bottom: 4, right: 4),
                  onTap: () {
                    Get.to(() => ChangeLanguagePage());
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 12, right: 8),
                  child: Text(
                    AppStrings().labelSecurity,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.black, fontSize: 16),
                  ),
                ),
                generateListItem(
                    label: AppStrings().labelLocalAuthentication,
                    value: isLocalAuth,
                    onChanged: (bool value) {
                      setState(() {
                        isLocalAuth = !isLocalAuth;
                        SharedPreferencesHelper.setLocalAuth(value);
                      });
                    }),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 12, right: 8),
                  child: Text(
                    AppStrings().Others,
                    style: AppTextStyle.textBoldStyle(
                        color: AppColors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          DialogHelper.showInfoDialog(
                              title: AppStrings().infoString,
                              description: AppStrings().comingSoon);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 10),
                          child: Text(
                            AppStrings().aboutUs,
                            style: AppTextStyle.textNormalStyle(
                                fontSize: 16, color: AppColors.testColor),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          NewConfirmationDialog(
                              context: context,
                              title: AppStrings().logoutTitle,
                              description: AppStrings().logoutDescription,
                              submitButtonText: "",
                              onCancelTap: () {
                                Navigator.pop(context);
                              },
                              onSubmitTap: () {
                                logout();
                              }).showAlertDialog();
                        },
                        child: Container(
                          height: 80,
                          width: width,
                          padding: const EdgeInsets.only(top: 30, bottom: 10),
                          child: Text(
                            AppStrings().logoutTitle,
                            style: AppTextStyle.textNormalStyle(
                                fontSize: 16, color: AppColors.testColor),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          DialogHelper.showInfoDialog(
                              title: AppStrings().infoString,
                              description: AppStrings().comingSoon);
                        },
                        child: Container(
                          height: 40,
                          width: width,
                          padding: const EdgeInsets.only(top: 10, bottom: 0),
                          child: Text(
                            AppStrings().deleteAccount,
                            style: AppTextStyle.textNormalStyle(
                                fontSize: 16, color: AppColors.testColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  generateListItem(
      {required String label,
      required bool value,
      required Function(bool value) onChanged}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SwitchListTile(
            contentPadding:
                const EdgeInsets.only(left: 16, top: 0, bottom: 4, right: 0),
            title: Text(
              label,
              style: AppTextStyle.textNormalStyle(
                  fontSize: 16, color: AppColors.testColor),
            ),
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.doctorNameColor,
            inactiveTrackColor: AppColors.grey8B8B8B,
            inactiveThumbColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  ///LOGOUT USER API
  logout() async {
    showProgressDialog();
    Get.back();

    FCMTokenModel fcmTokenModel = FCMTokenModel();
    fcmTokenModel.userName = getUserDetailsResponseModel?.id;
    fcmTokenModel.deviceId = await _getId();

    log("${json.encode(fcmTokenModel)}", name: "LOGOUT MODEL");

    await postLogoutController.postLogoutDetails(logoutDetails: fcmTokenModel);

    if (postLogoutController.logoutResponse["status"] == 200) {
      hideProgressDialog();
      SharedPreferencesHelper.setAutoLoginFlag(false);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      Get.offAll(() => BaseLoginPage());
    } else {
      hideProgressDialog();
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return null;
  }

  // logout() async {
  //   Get.back();
  //   SharedPreferencesHelper.setAutoLoginFlag(false);
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   await preferences.clear();
  //   Get.offAll(() => BaseLoginPage());
  // }

  void showProgressDialog() {
    setState(() {
      _loading = true;
    });
  }

  void hideProgressDialog() {
    setState(() {
      _loading = false;
    });
  }
}
