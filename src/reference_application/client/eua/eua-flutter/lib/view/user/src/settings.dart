import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uhi_flutter_app/common/src/dialog_helper.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/base_login_page.dart';
import 'package:uhi_flutter_app/widgets/src/new_confirmation_dialog.dart';

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

  ///DATA VARIABLES
  @override
  void initState() {
    super.initState();
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
    return Container(
      padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings().showNotification,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.doctorNameColor, fontSize: 16),
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
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: SizedBox(
              height: 1,
              width: MediaQuery.of(context).size.width,
              child: Container(color: AppColors.DARK_PURPLE.withOpacity(0.05)),
            ),
          ),
          Text(
            AppStrings().notificationInfoText,
            style: AppTextStyle.textLightStyle(
                color: AppColors.doctorNameColor, fontSize: 12),
          ),
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
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.doctorNameColor, fontSize: 16),
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
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.amountColor, fontSize: 16),
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
              height: 80,
              width: width,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                AppStrings().deleteAccount,
                style: AppTextStyle.textBoldStyle(
                    color: AppColors.amountColor, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  logout() async {
    Get.back();
    SharedPreferencesHelper.setAutoLoginFlag(false);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Get.offAll(() => BaseLoginPage());
  }
}
