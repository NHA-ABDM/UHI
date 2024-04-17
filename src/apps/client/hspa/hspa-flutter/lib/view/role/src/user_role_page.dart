import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/common/common.dart';
import 'package:hspa_app/constants/src/get_pages.dart';
import 'package:hspa_app/constants/src/strings.dart';
import 'package:hspa_app/theme/src/app_colors.dart';
import 'package:hspa_app/widgets/src/spacing.dart';

import '../../../constants/src/asset_images.dart';
import '../../../theme/src/app_text_style.dart';

class UserRolePage extends StatefulWidget {
  const UserRolePage({Key? key}) : super(key: key);

  @override
  State<UserRolePage> createState() => _UserRolePageState();
}

class _UserRolePageState extends State<UserRolePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBackgroundColor,
        shadowColor: Colors.black.withOpacity(0.1),
        //titleSpacing: 0,
        title: Text(
          AppStrings().roleAppBarTitle,
          style: AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 18),
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: ListView(
        children: [

          const Spacing(isWidth: false, size: 20,),
          buildUserRoleWidget(assetIcon: AssetImages.doctorWithBorder,
              userRole: AppStrings().doctor,
              onPressed: (){
            //Get.to(const MobileNumberAuthPage());
          }),
          const Spacing(isWidth: false, size: 30,),
          buildUserRoleWidget(assetIcon: AssetImages.therapistWithBorder,
              userRole: AppStrings().therapist,
              isUpcoming: true,
              onPressed: (){
            //Get.to(const MobileNumberAuthPage());
            }, isCenter: true),
          const Spacing(isWidth: false, size: 30,),
          buildUserRoleWidget(assetIcon: AssetImages.psychologistWithBorder,
              userRole: AppStrings().psychologist,
              isUpcoming: true,
              onPressed: (){
            //Get.to(const MobileNumberAuthPage());
            },
              isCenter: true),
          const Spacing(isWidth: false, size: 30,),
          buildUserRoleWidget(assetIcon: AssetImages.othersWithBorder,
              userRole: AppStrings().others,
              isUpcoming: true,
              onPressed: (){
            //Get.to(const MobileNumberAuthPage());
            },
              isCenter: true),
          const Spacing(isWidth: false, size: 20,),
        ],
      ),
    );
  }

  buildRoleWidget({required String assetIcon, required String userRole, required Function() onPressed, Color iconColor = Colors.white, bool isCenter = false}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.tileColors,
            ),
            Positioned(
              child: Image.asset(
                assetIcon,
                color: iconColor,
                height: 90,
                width: 90,
              ),
              top: isCenter? 15: 20,
              bottom: isCenter? 15: -15,
              left: 15,
            ),
          ],
        ),
        const Spacing(isWidth: false, size: 8,),
        SizedBox(width: 180,
          child: customSquareElevatedButton(
              text: userRole,
              onPressed: onPressed),
        ),
      ],
    );
  }

  buildUserRoleWidget({
    required String assetIcon,
    required String userRole,
    required Function() onPressed,
    bool isUpcoming = false,
    Color iconColor = Colors.white,
    bool isCenter = false}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 120, width: 120, child:  Image.asset(assetIcon),),
        const Spacing(isWidth: false, size: 8,),
        SizedBox(width: 240,
          child: customSquareElevatedButton(
              text: userRole,
              onPressed: () async{
                // Get.to(() => const MobileNumberAuthPage(fromRolePage: true,),
                //   transition: Utility.pageTransition,);
                if(isUpcoming) {
                  DialogHelper.showComingSoonView();
                } else {
                  /*Get.to(() => const LoginProviderPage(fromRolePage: true,),
                    transition: Utility.pageTransition,);*/
                  //Get.toNamed(AppRoutes.loginProviderPage, arguments: {'fromRolePage': true});

                  /*Get.to(() => const MobileNumberAuthPage(fromRolePage: true,),
                  transition: Utility.pageTransition,);*/
                  Get.toNamed(AppRoutes.mobileNumberAuthPage, arguments: {'fromRolePage': true});

                }
              }),
        ),
      ],
    );
  }

  customSquareElevatedButton(
      {required String text,
        Color textColor = Colors.white,
        Color borderColor = AppColors.amountColor,
        Color foregroundColor = AppColors.amountColor,
        Color backgroundColor = AppColors.amountColor,
        required Function() onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyle.textNormalStyle(color: textColor, fontSize: 16),
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
        visualDensity: VisualDensity.standard,
        elevation: MaterialStateProperty.all<double>(0),
        foregroundColor: MaterialStateProperty.all<Color>(foregroundColor),
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: BorderSide(color: borderColor)),
        ),
      ),
    );
  }
}
