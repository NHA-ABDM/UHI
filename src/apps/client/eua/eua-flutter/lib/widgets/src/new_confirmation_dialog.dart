///DEFAULT PACKAGES
import 'package:flutter/material.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/widgets/src/spacing.dart';

///USER DEFINED FILES

class NewConfirmationDialog {
  ///PARENT CONTEXT
  BuildContext context;

  ///CALLBACK FUNCTIONS
  Function() onCancelTap;
  Function() onSubmitTap;

  ///DIALOG CONTENTS
  String title;
  String description;
  String submitButtonText;

  ///DIALOG LAYOUT
  var width;
  var height;

  NewConfirmationDialog(
      {required this.context,
      required this.title,
      required this.description,
      required this.onCancelTap,
      required this.onSubmitTap,
      required this.submitButtonText});

  ///SHOW DIALOG FUNCTION
  showAlertDialog() {
    ///ASSIGNING TO VARIABLES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          buttonPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: AppColors.DARK_PURPLE,
            ),
            textAlign: TextAlign.left,
          ),
          content: Text(
            description,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: AppColors.doctorNameColor,
            ),
            textAlign: TextAlign.left,
          ),
          actions: [
            Container(
              height: 1,
              width: width,
              color: const Color.fromARGB(255, 238, 238, 238),
            ),
            SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // InkWell(
                  //   onTap: onCancelTap,
                  //   child: Container(
                  //     width: width * 0.35,
                  //     height: 50,
                  //     padding: EdgeInsets.all(8),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset(
                  //           'assets/images/cross.png',
                  //           height: 16,
                  //           width: 16,
                  //         ),
                  //         const SizedBox(
                  //           width: 8,
                  //         ),
                  //         Text(
                  //           AppStrings().no,
                  //           style: AppTextStyle.textLightStyle(
                  //               color: AppColors.testColor, fontSize: 12),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: showDoctorActionView(
                      assetImage: 'assets/images/cross.png',
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().no,
                      onTap: onCancelTap,
                    ),
                  ),
                  Container(
                    color: Color(0xFFF0F3F4),
                    height: 50,
                    width: 1,
                  ),
                  // InkWell(
                  //   onTap: onSubmitTap,
                  //   child: Container(
                  //     width: width * 0.35,
                  //     height: 50,
                  //     padding: EdgeInsets.all(8),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset(
                  //           'assets/images/Tick-Square.png',
                  //           height: 16,
                  //           width: 16,
                  //         ),
                  //         const SizedBox(
                  //           width: 8,
                  //         ),
                  //         Text(
                  //           AppStrings().yes,
                  //           style: AppTextStyle.textLightStyle(
                  //               color: AppColors.testColor, fontSize: 12),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: showDoctorActionView(
                      assetImage: 'assets/images/Tick-Square.png',
                      color: AppColors.infoIconColor,
                      actionText: AppStrings().yes,
                      onTap: onSubmitTap,
                    ),
                  ),
                ],
              ),
            ),

            ///SUBMIT BUTTON
          ],
        );
      },
    );
  }

  showDoctorActionView(
      {required String assetImage,
      required Color color,
      required String actionText,
      required Function() onTap}) {
    return SizedBox(
      height: 60,
      child: InkWell(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.pressed)
              ? color.withAlpha(50)
              : null;
        }),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              assetImage,
              height: 16,
              width: 16,
            ),
            Spacing(size: 5),
            Text(
              actionText,
              style: AppTextStyle.textLightStyle(
                  color: AppColors.testColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
