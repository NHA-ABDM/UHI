import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({Key? key, this.isChange = true}) : super(key: key);
  final bool isChange;

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  @override
  Widget build(BuildContext context) {
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
          widget.isChange
              ? AppStrings().labelChangeLanguage
              : AppStrings().labelSelectLanguage,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return ListView(
      shrinkWrap: true,
      children: [
        generateListItem(
            label: AppStrings().labelEnglish,
            locale: "en",
            onPressed: () async {
              await setLocale(const Locale('en'));
            }),
        generateListItem(
            label: AppStrings().labelHindi,
            locale: "hi",
            onPressed: () async {
              await setLocale(const Locale('hi'));
            }),
      ],
    );
  }

  generateListItem(
      {required String label,
      required String locale,
      required Function() onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      label,
                      style: AppTextStyle.textNormalStyle(
                          fontSize: 16, color: AppColors.testColor),
                    ),
                  ),
                ),
                Get.locale.toString() == locale
                    ? Icon(Icons.check, size: 20)
                    : Container(),
              ],
            ),
          ),
        ),
        const Divider(
          color: AppColors.DARK_PURPLE,
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  setLocale(Locale locale) async {
    await context.setLocale(locale);
    Get.updateLocale(locale);
  }
}
