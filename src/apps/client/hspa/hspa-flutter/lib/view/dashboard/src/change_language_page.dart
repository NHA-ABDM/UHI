import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../constants/src/language_constant.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({Key? key}) : super(key: key);
  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {

  /// Arguments
  bool isChange = true;
  late Locale? selectedLocale;

  @override
  void initState() {
    /// Get Arguments
    if(Get.arguments['isChange'] != null) {
      isChange = Get.arguments['isChange'];
    }
    selectedLocale = Get.locale;
    super.initState();
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
          isChange ? AppStrings().labelChangeLanguage : AppStrings().labelSelectLanguage,
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
        generateListItem(label: AppStrings().labelEnglish, onPressed: (){
          if(selectedLocale != LanguageConstant.supportedLanguages[0]) {
            selectedLocale = LanguageConstant.supportedLanguages[0];
            setLocale(LanguageConstant.supportedLanguages[0]);
          }
        }, locale : LanguageConstant.supportedLanguages[0]),
        generateListItem(label: AppStrings().labelHindi, onPressed: (){
          if(selectedLocale != LanguageConstant.supportedLanguages[1]) {
            setLocale(LanguageConstant.supportedLanguages[1]);
            selectedLocale = LanguageConstant.supportedLanguages[1];
          }
        }, locale: LanguageConstant.supportedLanguages[1]),
      ],
    );
  }

  generateListItem({required String label, required Function() onPressed, required Locale locale}){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 4),
          child: ListTile(
            title: Text(label, style: AppTextStyle.textNormalStyle(fontSize: 16, color: AppColors.testColor),),
            onTap: onPressed,
            trailing: selectedLocale == null
                ? const SizedBox()
                : selectedLocale!.languageCode == locale.languageCode
                    ? const Icon(
                        Icons.check,
                        color: AppColors.tileColors,
                        size: 32,
                      )
                    : const SizedBox(),
          ),
        ),
        const Divider(color: AppColors.drawerDividerColor, thickness: 1, height: 1,),
      ],
    );
  }

  setLocale(Locale locale) async {
    await context.setLocale(locale);
    Get.updateLocale(locale);
  }
}
