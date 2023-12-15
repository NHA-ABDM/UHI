import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/widgets/widgets.dart';

import '../../../constants/src/strings.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../widgets/src/square_rounded_button.dart';
import '../../../widgets/src/vertical_spacing.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Text(
          AppStrings().signUpAppBarTitle,
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
    return Column(
      children: [
        const Spacing(
          isWidth: false,
          size: 24,
        ),
        Align(
            alignment: Alignment.center,
            child: Text(
              AppStrings().labelGenerateHPRId,
              style: AppTextStyle.textSemiBoldStyle(
                  fontSize: 14, color: AppColors.titleTextColor),
            ),
        ),
        const Spacing(
          isWidth: false,
          size: 24,
        ),
        Expanded(child: buildUserRoleWidget(assetIcon: AssetImages.aadhaar, userRole: AppStrings().btnAadhaar, onPressed: () {
          /*Get.to(() => const SignUpWithAadhaarPage(),
            transition: Utility.pageTransition,);*/
          Get.toNamed(AppRoutes.signUpWithAadhaarPage);
        }),),
        Row(
          children:  [
            const Expanded(child: Divider(color: AppColors.lightTextColor, thickness: 1, endIndent: 5,)),
            Text(AppStrings().labelOr, style: AppTextStyle.textSemiBoldStyle(fontSize: 16, color: AppColors.lightTextColor),),
            const Expanded(child: Divider(color: AppColors.lightTextColor, thickness: 1, indent: 5)),
          ],
        ),
        Expanded(child: buildUserRoleWidget(assetIcon: AssetImages.aadhaar, userRole: AppStrings().btnDrivingLicense, onPressed: () {}),)
      ],
    );
  }

  buildUserRoleWidget({required String assetIcon, required String userRole, required Function() onPressed, Color iconColor = Colors.white, bool isCenter = false}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 120, width: 120, child:  Image.asset(assetIcon),),
        VerticalSpacing(size: 8,),
        SizedBox(width: 200,
          child: SquareRoundedButton(
              text: userRole,
              onPressed: onPressed),
        ),
      ],
    );
  }


}
