import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/settings/src/preferences.dart';

import '../../../constants/src/language_constant.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool newAppointmentValue = true;
  bool rescheduledAppointmentValue = true;
  bool cancelledAppointmentValue = false;
  bool chatsValue = false;
  bool paymentsValue = true;
  bool ratingsValue = false;
  bool _isLocalAuth = false;
  String selectedLanguage = AppStrings().labelEnglish;

  @override
  void initState() {

    _isLocalAuth = Preferences.getBool(key: AppStrings.isLocalAuth) ?? false;
    getSelectedLanguage();

    super.initState();
  }

  void getSelectedLanguage() {
    selectedLanguage = AppStrings().labelEnglish;
    Locale? locale = Get.locale;
    debugPrint('Selected local code is ${locale?.languageCode}');
    if (locale != null) {
      switch (locale.languageCode) {
        case LanguageConstant.englishCode:
          selectedLanguage = AppStrings().labelEnglish;
          break;
          case LanguageConstant.hindiCode:
          selectedLanguage = AppStrings().labelHindi;
          break;
      }
    }

    if(mounted){
      setState(() {
      });
    }
    debugPrint('selectedLanguage $selectedLanguage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().labelSettings,
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
                  child: Text(AppStrings().labelSettingsAndPreferences,
                    style:
                    AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),),
                ),

                ListTile(
                  dense: true,
                  title: Text(
                    AppStrings().labelNotificationSettings,
                    style: AppTextStyle.textNormalStyle(
                        fontSize: 16,
                        color: AppColors.testColor
                    ),
                  ),
                  trailing: const Icon(Icons.navigate_next, size: 36, color: AppColors.testColor,),
                  contentPadding: const EdgeInsets.only(left: 20, top: 8, bottom: 0, right: 4),
                  onTap: () {
                    Get.toNamed(AppRoutes.notificationSettingsPage);
                  },
                ),

                ListTile(
                  dense: true,
                  title: Text(
                    AppStrings().labelChangeLanguage,
                    style: AppTextStyle.textNormalStyle(
                        fontSize: 16,
                        color: AppColors.testColor
                    ),
                  ),
                  subtitle: Text(
                    AppStrings().labelChosenLanguage(selectedLanguage: selectedLanguage),
                    style: AppTextStyle.textNormalStyle(
                        fontSize: 12,
                        color: AppColors.testColor
                    ),

                  ),
                  trailing: const Icon(Icons.navigate_next, size: 36, color: AppColors.testColor,),
                  contentPadding: const EdgeInsets.only(left: 20, top: 0, bottom: 4, right: 4),
                  onTap: () async{
                    await Get.toNamed(AppRoutes.changeLanguagePage, arguments: {'isChange': true});
                    getSelectedLanguage();
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
                  padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
                  child: Text(AppStrings().labelSecurity,
                    style:
                    AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),),
                ),

                generateListItem(label: AppStrings().labelLocalAuthentication, value:  _isLocalAuth, onChanged: (bool value) {
                  setState(() {
                    _isLocalAuth = !_isLocalAuth;
                    Preferences.saveBool(key: AppStrings.isLocalAuth, value: _isLocalAuth);
                  });
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  generateListItem({required String label, required bool value, required Function(bool value) onChanged}){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SwitchListTile(
            title: Text(label, style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.testColor),),
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.tileColors,
            inactiveTrackColor: AppColors.grey8B8B8B,
            inactiveThumbColor: AppColors.white,
          ),
        ),

        /*Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4),
          child: ListTile(
            title: Text(label, style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.testColor),),
            trailing: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.tileColors,
              trackColor: AppColors.grey8B8B8B,
              thumbColor: AppColors.white,
            ),
            onTap: (){
              onChanged(value);
            },
          ),
        ),*/
        //const Divider(color: AppColors.drawerDividerColor, thickness: 1, height: 1,),
      ],
    );
  }
}
