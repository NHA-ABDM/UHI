import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/constants/src/asset_images.dart';
import 'package:hspa_app/widgets/src/square_rounded_button_with_icon.dart';
import 'package:hspa_app/widgets/widgets.dart';

import '../../../constants/src/strings.dart';
import '../../../constants/src/web_urls.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import '../../../utils/src/utility.dart';
import '../../authentication/src/register_provider_page.dart';

class ProfileNotFoundPage extends StatelessWidget {
  const ProfileNotFoundPage({Key? key}) : super(key: key);

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
          AppStrings().profileNotFoundAppBarTitle,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
          onPressed: () {
            Get.back(result: false);
          },
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return Column(
      children: [
        Container(
          height: 150,
          color: AppColors.tileColors,
          alignment: Alignment.center,
          child: Text(
            AppStrings().profileNotFound,
            style: AppTextStyle.textMediumStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SquareRoundedButtonWithIcon(
                    text: AppStrings().btnUseDifferentNumber,
                    assetImage: AssetImages.signUpMobile,
                    backgroundColor: AppColors.white,
                    borderColor: AppColors.tileColors,
                    textColor: AppColors.tileColors,
                    foregroundColor: AppColors.white,
                    onPressed: (){
                      Get.back(result: true);
                    }
                ),
                Spacing(isWidth: false, size: 12,),
                SquareRoundedButtonWithIcon(
                    text: AppStrings().btnSignUp,
                    assetImage: AssetImages.logIn,
                    backgroundColor: AppColors.tileColors,
                    borderColor: AppColors.tileColors,
                    textColor: AppColors.white,
                    foregroundColor: AppColors.tileColors,
                    onPressed: (){
                      /*Get.to(() => const SignUpPage(),
                        transition: Utility.pageTransition,);*/
                      //WebUrls.launchWebUrl(webUrl: WebUrls.hprBetaUrl);
                      Get.to(() => const RegisterProviderPage(),
                        transition: Utility.pageTransition,);
                    }
                ),
                Spacing(isWidth: false, size: 36,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
