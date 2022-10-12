import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hspa_app/widgets/src/vertical_spacing.dart';
import 'package:hspa_app/widgets/widgets.dart';
import '../../../widgets/src/square_rounded_button.dart';

import '../../../constants/src/get_pages.dart';
import '../../../constants/src/strings.dart';
import '../../../settings/src/preferences.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';

class ProminentDisclosurePage extends StatefulWidget {
  const ProminentDisclosurePage({Key? key}) : super(key: key);

  @override
  State<ProminentDisclosurePage> createState() =>
      _ProminentDisclosurePageState();
}

class _ProminentDisclosurePageState extends State<ProminentDisclosurePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            shadowColor: AppColors.tileColors,
            elevation: 0,
            titleSpacing: 24,
            title: Text(
              AppStrings().titleProminentDisclosure,
              style: AppTextStyle.textBoldStyle(
                  color: AppColors.black, fontSize: 18),
            ),
          ),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              children: [
                Text(
                  AppStrings().descProminentDisclosure,
                  style: AppTextStyle.textNormalStyle(fontSize: 13, color: AppColors.hintTextColor),
                ),
                VerticalSpacing(size: 16),
                Text(
                  AppStrings().camera,
                  style: AppTextStyle.textBoldStyle(fontSize: 16, color: AppColors.tileColors),
                ),
                VerticalSpacing(size: 8),
                Text(
                  AppStrings().descCamera,
                  style: AppTextStyle.textNormalStyle(fontSize: 13, color: AppColors.hintTextColor),
                ),
                VerticalSpacing(size: 16),
                Text(
                  AppStrings().labelMicrophone,
                  style: AppTextStyle.textBoldStyle(fontSize: 16, color: AppColors.tileColors),
                ),
                VerticalSpacing(size: 8),
                Text(
                  AppStrings().descMicrophone,
                  style: AppTextStyle.textNormalStyle(fontSize: 13, color: AppColors.hintTextColor),
                ),
                VerticalSpacing(size: 16),
                Text(
                  AppStrings().labelStorage,
                  style: AppTextStyle.textBoldStyle(fontSize: 16, color: AppColors.tileColors),
                ),
                VerticalSpacing(size: 8),
                Text(
                  AppStrings().descStorage,
                  style: AppTextStyle.textNormalStyle(fontSize: 13, color: AppColors.hintTextColor),
                ),
                VerticalSpacing(size: 16),
                Text(
                  AppStrings().labelSMS,
                  style: AppTextStyle.textBoldStyle(fontSize: 16, color: AppColors.tileColors),
                ),
                VerticalSpacing(size: 8),
                Text(
                  AppStrings().descSMS,
                  style: AppTextStyle.textNormalStyle(fontSize: 13, color: AppColors.hintTextColor),
                ),
                VerticalSpacing(size: 16),
                Text(
                  AppStrings().labelSharingOfData,
                  style: AppTextStyle.textBoldStyle(fontSize: 16, color: AppColors.tileColors),
                ),
                VerticalSpacing(size: 8),
                Text(
                  AppStrings().descSharingOfData,
                  style: AppTextStyle.textNormalStyle(fontSize: 13, color: AppColors.hintTextColor),
                ),
              ],
            ),
          ),
          VerticalSpacing(size: 4,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              Expanded(
                child: SquareRoundedButton(
                    text: AppStrings().btnDecline,
                    backgroundColor: AppColors.white,
                    borderColor: AppColors.tileColors,
                    textColor: AppColors.tileColors,
                    textStyle: AppTextStyle.textMediumStyle(color: AppColors.tileColors),
                    onPressed: () {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }
                }),
              ),
              Spacing(size: 16,),
              Expanded(
                child: SquareRoundedButton(
                    text: AppStrings().btnAccept.toUpperCase(),
                    textStyle: AppTextStyle.textMediumStyle(color: AppColors.white),
                    onPressed: () {
                  Preferences.saveBool(key: AppStrings.isProminentDisclosureAgreed, value: true);
                  Get.offAllNamed(AppRoutes.userRolePage);
                }),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
